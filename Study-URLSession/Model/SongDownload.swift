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
    
    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    func fetchSongAtUrl(_ item: URL) {
        downloadUrl = item
        downloadTask = urlSession.downloadTask(with: item)
        downloadTask?.resume()
    }
    
}

extension SongDownload: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
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
    
}
