//
//  SearchJSON.swift
//  RepoViewer
//
//  Created by vas on 08.10.2020.
//

import Foundation
import SwiftSoup
import UIKit

struct SearchResult: Codable{
    
    enum CodingKeys: CodingKey{
        case items
    }
    
    
    var items: [SearchItem]
    
    var lastShownIndex = -1
    var maxIndex = RepoSearcher.numOfItemsInRequest - 1
    
    func firstIndex(of item: SearchItem) -> Int?{
        for index in items.indices{
            if items[index].id == item.id{
                return index
            }
        }
        return nil
    }
}



struct SearchItem: Identifiable, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case id,name,owner,language,htmlUrl,createdAt,pushedAt,stargazersCount,url
    }
    
    
    init(from decoder: Decoder) throws {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        stargazersCount = try container.decode(Int.self, forKey: .stargazersCount)
        let dateOfCreationStr = try? container.decode(String.self, forKey: .createdAt)
        let dateOfLastPushStr = try? container.decode(String.self, forKey: .pushedAt)
        
        if let dateOfCreationStr = dateOfCreationStr{
            createdAt = dateFormatter.date(from: dateOfCreationStr)
        } else {createdAt = nil}
        
        if let dateOfLastPushStr = dateOfLastPushStr{
            pushedAt = dateFormatter.date(from: dateOfLastPushStr)
        } else {pushedAt = nil}
        
        owner = try container.decode(Owner.self, forKey: .owner)
        htmlUrl = try container.decode(URL.self, forKey: .htmlUrl)
        language = (try? container.decode(String.self, forKey: .language)) ?? "No language"
        url = try container.decode(URL.self, forKey: .url)
    }
    

    let id: Int
    let name: String
    let owner: Owner
    let htmlUrl: URL
    let stargazersCount: Int
    let language: String
    let createdAt: Date?
    let pushedAt: Date?
    let url: URL
    
    
    var imageType: ImageType?
    var imageData: Any?
    var imageSize: CGSize?
    
    var possibleImages = [URL]()
  
    var dateOfCreationToDisplay: String{
        guard let createdAt = createdAt else { return "Unknown" }
        return convertDate(date: createdAt)
    }

    
    var dateOfLastPushToDisplay: String{
        guard let pushedAt = pushedAt else { return "Unknown" }
        return convertDate(date: pushedAt)
    }
    

    private func convertDate(date: Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }

    
    struct Owner: Codable {
        
        let login: String
        let url: URL?
    }

}

enum ImageType{
    case svg, gif, otherType
}
