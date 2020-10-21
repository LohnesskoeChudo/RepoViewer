//
//  RequestFormer.swift
//  RepoViewer
//
//  Created by vas on 11.10.2020.
//
import Foundation

class RequestFormer{
        
    private static var searchFilter: SearchFilter!
    private static var input: String!
    
    
    static func formSearchRequest(input: String, filter: SearchFilter) -> URLRequest{
        self.input = input
        self.searchFilter = filter
        var request = URLRequest(url: formRequestUrl())
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        return request
    }
   
    private static let sortByVariations = ["Stars":"stars", "Last pushed":"updated"]
    private static func formRequestUrl() -> URL{
        
        let scheme = "https"
        let host = "api.github.com"
        let path = "/search/repositories"
        
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        var queryItems = [URLQueryItem]()
        var searchQuery = input!
        
        if searchFilter.placeToSearch != "Both"{
            searchQuery += "+in:\(searchFilter.placeToSearch.lowercased())"
        }
        if searchFilter.language != "Any language"{
            searchQuery += "+language:\(searchFilter.languages[searchFilter.language]!.aliases?[0] ?? searchFilter.language)"
        }
        
        searchQuery += formStarsSubQuery()
        searchQuery += formDateSubQuery(target: "+created:",
                                  lowerBound: searchFilter.lowerCreationDateBound,
                                  upperBound: searchFilter.upperCtrationDateBound,
                                  specifyLower: searchFilter.specifyLowerCreationDateBound,
                                  specifyUpper: searchFilter.specifyUpperCreationDateBound)
        searchQuery += formDateSubQuery(target: "+pushed:",
                                  lowerBound: searchFilter.lowerPushDateBound,
                                  upperBound: searchFilter.upperPushDateBound,
                                  specifyLower: searchFilter.specifyLowerPushDateBound,
                                  specifyUpper: searchFilter.specifyUpperPushDateBound)
        queryItems.append(URLQueryItem(name: "q", value: searchQuery))
        
        
        if searchFilter.sortBy != "Best match"{
            let sortQuery = Self.sortByVariations[self.searchFilter.sortBy]!
            let orderQuery = searchFilter.ascending ? "asc" : "desc"
            
            queryItems.append(URLQueryItem(name: "sort", value: sortQuery))
            queryItems.append(URLQueryItem(name: "order", value: orderQuery))
        }
        
        queryItems.append(URLQueryItem(name: "per_page", value: String(RepoSearcher.numOfItemsInRequest)))
        queryItems.append(URLQueryItem(name: "page", value: "1"))
        
        components.queryItems = queryItems
        print(components.url!)
        
        return components.url!
    }
    

    private static func formDateSubQuery(target: String, lowerBound: Date, upperBound: Date, specifyLower: Bool, specifyUpper: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if specifyLower && specifyUpper{
            
            let lowerBound = dateFormatter.string(from: lowerBound)
            let upperBound = dateFormatter.string(from: upperBound)
            
            return target + "\(lowerBound)..\(upperBound)"

        } else if specifyLower {
            return target + ">=" + dateFormatter.string(from: lowerBound)
        } else if specifyUpper {
            return target + "<=" + dateFormatter.string(from: upperBound)
        } else {
            return ""
        }
    }
    
    
    
    private static func formStarsSubQuery() -> String{
        let subQuery = "+stars:"
        if searchFilter.maxStarsConstraintIsActive && searchFilter.minStarsConstraintIsActive{
            if searchFilter.minNumOfStars == searchFilter.maxNumOfStars{
                return subQuery + searchFilter.minNumOfStars
            } else {
                return subQuery + "\(searchFilter.minNumOfStars)..\(searchFilter.maxNumOfStars)"
            }
        } else if searchFilter.minStarsConstraintIsActive{
            return subQuery + ">=" + searchFilter.minNumOfStars
        } else if searchFilter.maxStarsConstraintIsActive{
            return subQuery + "<=" + searchFilter.maxNumOfStars
        } else {return ""}
    }
}
