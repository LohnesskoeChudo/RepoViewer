//
//  Slyle.swift
//  RepoViewer
//
//  Created by vas on 11.10.2020.
//

import SwiftUI


struct StyledButtonBackground: ViewModifier{
    func body(content: Content) -> some View {
        content.foregroundColor(.primary).padding(.all, 10).background(RoundedRectangle(cornerRadius: 10).opacity(0.1))
    }
}



extension View{
    func styledButton() -> some View {
        self.modifier(StyledButtonBackground())
    }
}



struct AnimatableSystemFontModifier: AnimatableModifier {
    var size: CGFloat
    var animatableData: CGFloat{
        get{
            size
        }
        
        set{
            size = newValue
        }
    }
    
    func body(content: Content) -> some View {
        content.font(Font.system(size: size))
    }
}

extension View{
    func animatableSystemFont(size: CGFloat) -> some View{
        self.modifier(AnimatableSystemFontModifier(size: size))
    }
}
