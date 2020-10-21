//
//  RepoSearcher.swift
//  RepoViewer
//
//  Created by vas on 08.10.2020.
//

import SwiftUI
import SwiftSoup
import SwiftyGif
import SVGKit

class RepoSearcher: ObservableObject{
    
    @Published var items = [SearchItem]()
    @Published var searchFilter = SearchFilter()
    @Published var moreItemsAreAvailable = true
    @Published var resultsAreShown = false
    @Published var loading = false
    @Published var noConnection = false
    @Published var apiError = false
    @Published var nothingFound = false
    
    static let numOfItemsInRequest = 50
    static let maxPages = 10
    static let itemsPerPage = 10
    static let minimumLogoWidth: CGFloat = 190
    static let minimumLogoHeight: CGFloat = 90
    static let maxImagesPerItemToLoad: Int = 10
    private( set ) var result: SearchResult?
    private( set ) var lastRequestId: UUID!
    
    var lastShownItemIndex = -1
    var input = ""
    
    
    func findRepos(){
        let currentRequestId = UUID()
        self.lastRequestId = currentRequestId
        clear()
        withAnimation(Animation.easeInOut.repeatForever(autoreverses: true)){
            loading = true
        }
        let urlRequest = RequestFormer.formSearchRequest(input: input, filter: searchFilter)
        URLSession.shared.dataTask(with: urlRequest){ data, response, dataTaskError in
            guard currentRequestId == self.lastRequestId else {return}
            DispatchQueue.main.async {
                self.items = []
                withAnimation(Animation.easeInOut){
                    self.loading = false
                }
            }
            if let data = data{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                do{
                    let decodedData = try decoder.decode(SearchResult.self, from: data)
                    DispatchQueue.main.async{
                        self.result = decodedData
                        self.showMore(currentRequestId)
                        withAnimation(Animation.easeInOut){
                            self.resultsAreShown = true
                            if self.result!.items.count == 0{
                                self.nothingFound = true
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        withAnimation{
                            self.apiError = true
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    withAnimation{
                        self.noConnection = true
                    }
                }
            }
            DispatchQueue.main.async {
                closeKeyboard()
            }
        }.resume()
    }
    
    
    func clear(){
        withAnimation(Animation.easeInOut){
            resultsAreShown = false
            noConnection = false
            apiError = false
            loading = false
            nothingFound = false
        }
        result = nil
        moreItemsAreAvailable = true
        lastShownItemIndex = -1
    }

    
    func recreateFilter(){
        searchFilter = SearchFilter()
    }


    func showMore(_ posibleCurrentReqId: UUID?){
        let currentReqId: UUID!
        if posibleCurrentReqId == nil{
            currentReqId = UUID()
            self.lastRequestId = currentReqId
        } else {
            currentReqId = posibleCurrentReqId!
        }
        if result!.lastShownIndex + 1 + Self.itemsPerPage >= result!.items.count {
            withAnimation{
                moreItemsAreAvailable = false
            }
        }
        if result!.lastShownIndex < result!.items.count - 1{
            let numOfItems = min(Self.itemsPerPage, result!.items.count - 1 - result!.lastShownIndex)
            let lowerBound = self.result!.lastShownIndex+1
            let upperBound = self.result!.lastShownIndex+numOfItems
            if lowerBound <= upperBound{
                let slice = lowerBound...upperBound
                withAnimation(Animation.easeInOut){
                    self.items.append(contentsOf: self.result!.items[slice])
                }
                self.showItemsLogos(currentReqId)
                self.lastShownItemIndex = self.items.count - 1
                result!.lastShownIndex += numOfItems
            }
        }
    }
    
    
    private func getParsingZone(el: SwiftSoup.Element, maxHeaders: Int) -> SwiftSoup.Elements{
        let headers: Set<String> = ["h1","h2","h3","h4","h5","h6","header"]
        let children = el.children().array()
        var headersMet = 0
        for childIndex in children.indices{
            if headers.contains(children[childIndex].tagName()){
                headersMet += 1
            }
            if headersMet == maxHeaders{
                return Elements(Array(children[0..<childIndex]))
            }
        }
        return Elements(children)
    }

    
    
    private func loadImage(item: SearchItem, _ currenReqId: UUID){
        var itemIndex: Int!
        for index in self.items.indices{
            if self.items[index].name == item.name{
                itemIndex = index
                break
            }
        }
        loadHtml(item: item, itemIndex: itemIndex, currentReqId: currenReqId)
    }
    
    private func loadHtml(item: SearchItem, itemIndex: Int, currentReqId: UUID){
        URLSession.shared.dataTask(with: item.htmlUrl){ data, response, error in
            guard currentReqId == self.lastRequestId else {return}
            if let html = data{
                let htmlStr = String(data: html, encoding: .utf8)
                let doc = try! SwiftSoup.parse(htmlStr!)
                guard let mdField = try? doc.select("article.markdown-body").first else {return}

                let parsingZone = self.getParsingZone(el: mdField, maxHeaders: 3)
                if let images = try? parsingZone.select("img"){
                    let upperBound = min(images.count, Self.maxImagesPerItemToLoad)
                    for imageElement in images[0..<upperBound]{
                        if var imageUrl = try? imageElement.attr("src"){
                            imageUrl = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                            var components = URLComponents(string: imageUrl)!
                            if components.scheme == nil{
                                components.scheme = "https"
                                components.host = "github.com"
                            }

                            if let imageUrl = components.url{
                                guard currentReqId == self.lastRequestId && self.result != nil else {return}
                                self.result?.items[itemIndex].possibleImages.append(imageUrl)
                            }
                        }
                    }

                    DispatchQueue.global(qos: .userInitiated).async {
                        self.captureCorrectLogo(itemIndex: itemIndex, currentReqId)
                    }
                }
            }
        }.resume()
    }
    
    
    
    private func showItemsLogos(_ currentReqId: UUID){
        for itemIndex in self.lastShownItemIndex+1..<self.items.count{
            DispatchQueue.global(qos: .userInitiated).async {
                self.loadImage(item: self.items[itemIndex], currentReqId)
            }
        }
    }
    
    
    
    private func captureCorrectLogo(itemIndex: Int, _ currentReqId: UUID){
        
        if self.result != nil{
            for imageUrl in self.result!.items[itemIndex].possibleImages{
                let (data, _, _) = URLSession.shared.synchronousDataTask(with: imageUrl)
                if let data = data{
                    if let gifImage = try? UIImage(gifData: data,levelOfIntegrity: 0.5){
                            let size = UIImage(data: data)!.size
                            DispatchQueue.main.async{
                                withAnimation(Animation.easeInOut){
                                    guard currentReqId == self.lastRequestId else {return}
                                    self.items[itemIndex].imageType = .gif
                                    self.items[itemIndex].imageSize = size
                                    self.items[itemIndex].imageData = gifImage
                                }
                            }
                            return
                    }
                    if let uiImage = UIImage(data: data){
                        if uiImage.size.width > CGFloat(Self.minimumLogoWidth) && uiImage.size.height > CGFloat(Self.minimumLogoHeight){
                            DispatchQueue.main.async{
                                withAnimation(Animation.easeInOut){
                                    guard currentReqId == self.lastRequestId else {return}
                                    self.items[itemIndex].imageType = .otherType
                                    self.items[itemIndex].imageData = uiImage
                                    
                                }
                            }
                            return
                        }
                    }
                    if let svgImage = SVGKImage(data: data){
                        guard svgImage.hasSize() else {continue}
                        if svgImage.size.width > Self.minimumLogoWidth && svgImage.size.height > Self.minimumLogoHeight {
                            
                            DispatchQueue.main.async {
                                withAnimation(Animation.easeInOut){
                                    guard currentReqId == self.lastRequestId else {return}
                                    self.items[itemIndex].imageType = .svg
                                    self.items[itemIndex].imageSize = svgImage.size
                                    self.items[itemIndex].imageData = svgImage
                                    
                                }
                            }
                            return
                        }
                    }
                }
            }
        }
    }
}


