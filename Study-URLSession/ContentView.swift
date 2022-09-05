//
//  ContentView.swift
//  Study-URLSession
//
//  Created by David Malicke on 9/5/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SongDetailView(musicItem: .constant(musicItem))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
