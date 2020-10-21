//
//  RepoSearchView.swift
//  RepoViewer
//
//  Created by vas on 08.10.2020.
//


import SwiftUI

struct RepoSearchView: View{
    
    @EnvironmentObject var repoSearcher: RepoSearcher
    @State var navBarHidden = true
    @State var searchButtonIsActive = false
    
    
    var body: some View{
        
        let inputBinding = Binding(
            get: {repoSearcher.input},
            set: {repoSearcher.input = $0
                    if repoSearcher.input.count > 0{
                        searchButtonIsActive = true
                    } else {
                        searchButtonIsActive = false
                    }
                 })
        
        NavigationView{
            VStack(spacing: 0){
                HStack{
                    TextField("Enter repository here", text: inputBinding, onCommit: {})
                        .textFieldStyle(PlainTextFieldStyle())
                        .styledButton()
                    Button("Search",
                            action: repoSearcher.findRepos)
                        .styledButton()
                        .animation(nil)
                        .disabled(!searchButtonIsActive)
                        .opacity(!searchButtonIsActive ? 0.3 : 1)
                        .animation(Animation.easeInOut)
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                Divider()
                
                if repoSearcher.resultsAreShown{
                    if !repoSearcher.nothingFound{
                        result()
                    } else {
                        nothingFound()
                    }
                } else if repoSearcher.noConnection{
                    noConnection()
                } else if repoSearcher.apiError{
                    tryAgain()
                } else {
                    logo()
                }

                Divider()
                
                HStack{
                    Button(action: {
                            repoSearcher.clear()
                            closeKeyboard()
                    }){
                        Text("Clear")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .styledButton()
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    AdditionalLogicNavLink(
                        destination: FilterView(),
                        label:{
                            Text("Filter")
                                .frame(minWidth: 0,maxWidth: .infinity)
                                .styledButton()},
                        action: closeKeyboard)

                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .navigationBarTitle("",displayMode: .inline)
            .navigationBarHidden(navBarHidden)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    
    
    private func result() -> some View{
        GeometryReader{ geo in
        ScrollView(showsIndicators: false){
            Spacer(minLength: 20)
            VStack(spacing: 20){
                ForEach(repoSearcher.items, id: \.id){ item in
                    AdditionalLogicNavLink(
                        destination: RepoWebView(searchItem: item)
                            .navigationBarTitle("GitHub", displayMode: .inline),
                        label:{
                            ItemView(item: item, geo: geo)
                                .padding(.horizontal)},
                        action: closeKeyboard)
                }
                .transition(AnyTransition.opacity)
                
                if repoSearcher.moreItemsAreAvailable{
                    Button("Show more"){
                        repoSearcher.showMore(repoSearcher.lastRequestId)
                    }
                    .styledButton()
                }
            }
            Spacer(minLength: 20)
        }
        }
    }
    
    
    
    private func nothingFound() -> some View{
        GeometryReader{ geo in
            VStack{
                Spacer()
                Image(systemName: "xmark.circle")
                    .animatableSystemFont(size: min(geo.size.width, geo.size.height) * 0.5)
                    .foregroundColor(.blue)
                    .opacity(0.3)
                Text("Nothing found")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .opacity(0.5)
                    .padding(.top)
                Spacer()
            }
        }
    }
    
    
    
    private func logo() -> some View {
        GeometryReader{ geo in
            VStack{
                Spacer()
                VectorImageView(name: "octocat1")
                    .frame(width: min(geo.size.width, geo.size.height) * 0.66 , height: min(geo.size.width, geo.size.height) * 0.66)
                    .opacity(0.1)
                    .position(x: geo.size.width/2, y: geo.size.height/2)
                    .scaleEffect(repoSearcher.loading ? 1.15 : 1)
                    .overlay(
                        Group{
                            if repoSearcher.loading{
                                Text("Loading")
                                    .font(Font.system(size: min(geo.size.width, geo.size.height) * 0.08))
                                    .opacity(0.25)
                                    
                            }
                        })
                Spacer()
            }
        }
    }
    
    
    
    private func noConnection() -> some View{
        GeometryReader{ geo in
            VStack{
                Spacer()
                Image(systemName: "wifi.slash")
                    .animatableSystemFont(size: min(geo.size.width, geo.size.height) * 0.5)
                    .foregroundColor(.red)
                    .opacity(0.3)
                Text("No connection")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                    .opacity(0.5)
                    .padding(.top)
                Spacer()
            }
        }
    }
    
    
    
    private func tryAgain() -> some View{
        GeometryReader{ geo in
            VStack{
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .animatableSystemFont(size: min(geo.size.width, geo.size.height) * 0.5)
                    .foregroundColor(.orange)
                    .opacity(0.3)
                Text("Too many requests")
                    .font(.headline)
                    .padding(.top)
                    .opacity(0.5)
                Text("Try again in few seconds")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .opacity(0.5)
                    .padding(.top, 1)
                Spacer()
            }
        }
    }
}


