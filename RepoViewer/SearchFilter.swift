//
//  SearchFilter.swift
//  RepoViewer
//
//  Created by vas on 10.10.2020.
//
import SwiftUI
import Yams
    
struct SearchFilter{
    
    var languages: [String: Language]
    static let placesToSearch = ["Name" , "Description", "Both" ]
    static let sortByVariations = ["Stars", "Last pushed", "Best match"]
    
    init() {
        let yamlPath = Bundle.main.path(forResource: "languages", ofType: "yml")
        let fileManager = FileManager()
        let yamlData = fileManager.contents(atPath: yamlPath!)!

        let decoder = YAMLDecoder()
        var decodedLanguages = try! decoder.decode([String: Language].self, from: yamlData)
        decodedLanguages["Any language"] = nil
        languages = decodedLanguages
    }

    var sortBy = "Stars"
    var ascending = false
    var language = "Any language"
    var minNumOfStars = ""
    var maxNumOfStars = ""
    var minStarsConstraintIsActive = false
    var maxStarsConstraintIsActive = false
    var placeToSearch = "Both"
    
    var specifyLowerPushDateBound = false
    var specifyUpperPushDateBound = false
   
    var specifyLowerCreationDateBound = false
    var specifyUpperCreationDateBound = false
  
    var lowerPushDateBound = Date.today
    var upperPushDateBound = Date.today
    var lowerCreationDateBound = Date.today
    var upperCtrationDateBound = Date.today
   
    func orderIsAvailable() -> Bool{
        sortBy == "Best match" ? false : true
    }
    
    func someStarsBoundInputIsEmpty() -> Bool {
        (minNumOfStars.isEmpty && minStarsConstraintIsActive) ||
        (maxNumOfStars.isEmpty && maxStarsConstraintIsActive)
    }
    
    func starsBoundsInputIsCorrect() -> Bool {
        
        if maxStarsConstraintIsActive && minStarsConstraintIsActive{
            
            if let minNumOfStars = Int(minNumOfStars), let maxNumOfStars = Int(maxNumOfStars){
                if minNumOfStars <= maxNumOfStars{
                    return true
                }
            }

        } else if maxStarsConstraintIsActive {
            if let maxNumOfStars = Int(maxNumOfStars) {
                return maxNumOfStars >= 0 ? true : false
            }
            
        } else if minStarsConstraintIsActive {
            if let minNumOfStars = Int(minNumOfStars) {
                return minNumOfStars >= 0 ? true : false
            }
        }
        return !maxStarsConstraintIsActive && !minStarsConstraintIsActive ? true : false
    }
}


struct Language: Decodable {
    let aliases: [String]?
}
