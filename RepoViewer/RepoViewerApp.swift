//
//  RepoViewerApp.swift
//  RepoViewer
//
//  Created by vas on 08.10.2020.
//

import SwiftUI
import SwiftyGif

@main
struct RepoViewerApp: App {
    var body: some Scene {
        WindowGroup {
            RepoSearchView().environmentObject(RepoSearcher())
        }
    }
}
