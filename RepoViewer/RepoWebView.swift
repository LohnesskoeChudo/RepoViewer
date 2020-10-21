//
//  RepoWebView.swift
//  RepoViewer
//
//  Created by vas on 11.10.2020.
//

import SwiftUI
import WebKit

final class RepoWebView: UIViewRepresentable{
    
    var searchItem: SearchItem
    var request: URLRequest
    
    init(searchItem: SearchItem) {
        self.searchItem = searchItem
        request = URLRequest(url: searchItem.htmlUrl)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        
    }
}
