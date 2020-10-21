//
//  ItemView.swift
//  RepoViewer
//
//  Created by vas on 08.10.2020.
//

import SwiftUI

struct ItemView: View {
        
    let item: SearchItem
    let geo: GeometryProxy
    
    private var languageColor: Color{
        let hash = item.language.hashValue
        let red =  Double((hash & 0xff0000) >> 16) / 255
        let green = Double((hash & 0x00ff00) >> 8) / 255
        let blue = Double(hash & 0x0000ff) / 255
        
        return Color(red: red, green: green, blue: blue)
    }
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10).opacity(0.1)
            VStack(spacing: 10){
                HStack(spacing: 20){
                    Text(item.name)
                        .font(.headline)
                        .fontWeight(.heavy)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    HStack(spacing: 10){
                        Text("\(item.stargazersCount)")
                        Image(systemName: "star.fill")
                            .foregroundColor(Color.yellow)
                    }
                }
                HStack(alignment: .bottom){
                    VStack(alignment: .leading){
                        Text(item.owner.login)
                        HStack{
                            Circle()
                                .fill(languageColor)
                                .frame(width: 22, height: 22)

                            Text(item.language)
                            Spacer()
                        }
                    }
                    Spacer()
                    VStack(alignment: .center){
                        Text("Created: ").font(.caption) +
                        Text(item.dateOfCreationToDisplay)
                        Text("Pushed: ").font(.caption) +
                        Text(item.dateOfLastPushToDisplay)
                    }
                }
                ItemImageView(item: item, geo: geo)
            }
            .padding()
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

