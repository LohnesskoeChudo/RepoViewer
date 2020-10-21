//
//  FilterView.swift
//  RepoViewer
//
//  Created by vas on 08.10.2020.
//


import SwiftUI

struct FilterView: View{
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var repoSearcher: RepoSearcher
    @State var alertIsShowing = false
    @State var alertMessage = ""
    //need to resolve animation bug
    @State var navigationBarHidden = false

    
    var body: some View{
        
        let minStarConstraintBinding = createMinStarConstraintIsActiveBinding()
        let maxStarConstraintBinding = createMaxStarConstraintIsActiveBinding()

        Form {
            Section(header: Text("Search by").padding(.top)){
                Picker(selection: $repoSearcher.searchFilter.placeToSearch, label: Text("Search in")){
                    ForEach(SearchFilter.placesToSearch, id: \.self){ place in
                        Text(place)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section(header: Text("Sort by").padding(.top)){
                Picker(selection: $repoSearcher.searchFilter.sortBy, label: Text("Sort by")){
                    ForEach(SearchFilter.sortByVariations, id: \.self){ variant in
                        Text(variant)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                if repoSearcher.searchFilter.orderIsAvailable(){
                    Toggle("Ascending", isOn: $repoSearcher.searchFilter.ascending)
                }
            }
            Section{
                Toggle("Minimum number of stars", isOn: minStarConstraintBinding)
                if repoSearcher.searchFilter.minStarsConstraintIsActive{
                    TextField("Enter minimal number of stars", text: $repoSearcher.searchFilter.minNumOfStars)
                }
                Toggle("Maximum number of stars", isOn: maxStarConstraintBinding)
                if repoSearcher.searchFilter.maxStarsConstraintIsActive{
                    TextField("Enter maximal number of stars", text: $repoSearcher.searchFilter.maxNumOfStars)
                }
            }
            Section{
                
                AdditionalLogicNavLink(
                    destination: LanguageSelector(),
                    label:{
                        HStack{
                            Text("Choose language")
                            Spacer()
                            Group{
                                Text(repoSearcher.searchFilter.language)
                                Image(systemName: "chevron.right")
                            }.opacity(0.3)
                        }},
                    action: closeKeyboard)
                
            }
            Section{
                AdditionalLogicNavLink(
                    destination:
                        DateSpecifierView(specifyLowerBound: $repoSearcher.searchFilter.specifyLowerPushDateBound,
                                              specifyUpperBound: $repoSearcher.searchFilter.specifyUpperPushDateBound,
                                              lowerBound: $repoSearcher.searchFilter.lowerPushDateBound,
                                              upperBound: $repoSearcher.searchFilter.upperPushDateBound,
                                              navigationTitle: "Date of last push"),
                    label:{
                        HStack{
                            Text("Date of last push")
                            Spacer()
                            Image(systemName: "chevron.right").opacity(0.3)
                        }},
                    action: closeKeyboard)
                

                AdditionalLogicNavLink(
                    destination:
                        DateSpecifierView(specifyLowerBound: $repoSearcher.searchFilter.specifyLowerCreationDateBound,
                                          specifyUpperBound: $repoSearcher.searchFilter.specifyUpperCreationDateBound,
                                          lowerBound: $repoSearcher.searchFilter.lowerCreationDateBound,
                                          upperBound: $repoSearcher.searchFilter.upperCtrationDateBound,
                                          navigationTitle: "Date of creation"),
                    label:{
                        HStack{
                            Text("Date of creation")
                            Spacer()
                            Image(systemName: "chevron.right").opacity(0.3)
                        }},
                    action: closeKeyboard)
            }
            
            
            Section{
                Button("Reset filter settings"){repoSearcher.recreateFilter()}
            }
        }
        .navigationBarHidden(navigationBarHidden)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("Filter", displayMode: .inline)
        .navigationBarItems(trailing: Button("Done", action: donePressed))
        .alert(isPresented: $alertIsShowing){
            Alert(title: Text("Oops!"), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
    }
        
    
    
    private func donePressed(){
        if  repoSearcher.searchFilter.someStarsBoundInputIsEmpty() {
            alertMessage = "Some fields are emty."
            alertIsShowing = true
            return
        }
        if repoSearcher.searchFilter.starsBoundsInputIsCorrect(){
            navigationBarHidden = true
            presentationMode.wrappedValue.dismiss()
            return
        } else {
            alertMessage = "Please, correct your input."
            alertIsShowing = true
        }
    }
    
    
    
    private func createMinStarConstraintIsActiveBinding() -> Binding<Bool>{
        Binding(get: {
                    return repoSearcher.searchFilter.minStarsConstraintIsActive
                },
                set: { newValue in
                    if !newValue {
                        repoSearcher.searchFilter.minNumOfStars = ""
                    }
                    repoSearcher.searchFilter.minStarsConstraintIsActive = newValue
                }
        )
        
    }
        
    
    
    private func createMaxStarConstraintIsActiveBinding() -> Binding<Bool>{
        Binding(get: {
                    return repoSearcher.searchFilter.maxStarsConstraintIsActive
                },
                set: { newValue in
                    if !newValue {
                        repoSearcher.searchFilter.maxNumOfStars = ""
                    }
                    repoSearcher.searchFilter.maxStarsConstraintIsActive = newValue
                }
        )
    }
}



struct DateSpecifierView: View{
    
    @Binding var specifyLowerBound: Bool
    @Binding var specifyUpperBound: Bool
    @Binding var lowerBound: Date
    @Binding var upperBound: Date
    
    let navigationTitle: String
    
    var body: some View{
        Form{
            Section(header: ErrorMessage(message: "Incorrect bounds given", errorOcured: !inputIsCorrect()).padding(.top, 5)){
                Toggle("Specify lower bound", isOn: $specifyLowerBound)
                if specifyLowerBound{
                    HStack{
                        Spacer()
                        DatePicker("", selection: $lowerBound, in: lowestBound()...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                        Spacer()
                    }
                }
            }
            Section{
                Toggle("Specify upper bound", isOn: $specifyUpperBound)
                if specifyUpperBound{
                    HStack{
                        Spacer()
                        DatePicker("", selection: $upperBound, in: lowestBound()...Date(), displayedComponents: .date)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                        Spacer()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(!inputIsCorrect())
        .navigationTitle(navigationTitle)
    }
    
    
    
    private func lowestBound() -> Date{
        var components = DateComponents()
        components.year = 2008
        components.day = 1
        components.month = 1
        return Calendar.current.date(from: components)!
    }
    
    
    
    private func inputIsCorrect() -> Bool{
        specifyLowerBound && specifyUpperBound && lowerBound > upperBound ? false : true
    }
    
}


struct LanguageSelector: View{
        
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var repoSearcher: RepoSearcher
    @State var input: String = ""
    @State var searchedLanguages = [String]()
    
    var body: some View{
        
        let inputBinding = createInputBinding()
        
        return Form{
            Section{
                TextField("Start entering language", text: inputBinding)
            }
            Section{
                languageSelectionButton(language: "Any language")
            }
            ForEach(searchedLanguages, id: \.self){ language in
                languageSelectionButton(language: language)
            }
        }
    }
    
    private func languageSelectionButton(language: String) -> some View{
        Button(action:{
            closeKeyboard()
            repoSearcher.searchFilter.language = language
            presentationMode.wrappedValue.dismiss()
            }
        ){
            HStack{
                Text(language).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                if repoSearcher.searchFilter.language == language{
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func searchLanguages(){
        searchedLanguages = []
        
        guard input.count > 0 else {return}
        
        var tempSearchedLanguages = [String]()
        for language in repoSearcher.searchFilter.languages.keys{
            if language.lowercased().hasPrefix(input.lowercased()){
                tempSearchedLanguages.append(language)
            }
        }
        tempSearchedLanguages.sort()
        searchedLanguages = tempSearchedLanguages
    }
    
    private func createInputBinding() -> Binding<String>{
        Binding(
            get: {input},
            
            set: {
                
                input = $0
                searchLanguages()
            }
        )
    }
}



struct ErrorMessage: View{
    
    let message: String
    let errorOcured: Bool
    
    @ViewBuilder
    var body: some View{
        if errorOcured{
            Text(message)
                .foregroundColor(.red)
        }
    }
}
