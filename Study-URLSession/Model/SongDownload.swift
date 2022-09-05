//
//  SongDownload.swift
//  Study-URLSession
//
//  Created by David Malicke on 9/5/22.
//

import Foundation
import SwiftUI


class SongDownload: NSObject, ObservableObject {
    
    var downloadTask: URLSessionDownloadTask?
    var downloadUrl: URL?
    
    @Published var downloadLocation: URL?
    @Published var downloadedAmount: Float = 0
    @Published var isDownloading = false
    
    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    func fetchSongAtUrl(_ item: URL) {
        downloadUrl = item
        downloadTask = urlSession.downloadTask(with: item)
        downloadTask?.resume()
        isDownloading = true
    }
    
}

extension SongDownload: URLSessionDownloadDelegate {

    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        DispatchQueue.main.async {
            self.downloadedAmount = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        }
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for:.documentDirectory, in: .userDomainMask).first,
              let lastPathComponent = downloadUrl?.lastPathComponent else {
            fatalError()
        }
        
        let destinationUrl = documentsPath.appendingPathComponent(lastPathComponent)
        do {
            if fileManager.fileExists(atPath: destinationUrl.path) {
                try fileManager.removeItem(at: destinationUrl)
            }
            try fileManager.copyItem(at: location, to: destinationUrl)
            DispatchQueue.main.async {
                self.downloadLocation = destinationUrl
            }
            
        } catch {
            print(error)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        DispatchQueue.main.async {
            self.isDownloading = false
        }
        
    }
    
}
