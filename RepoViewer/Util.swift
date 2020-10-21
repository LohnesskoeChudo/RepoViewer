//
//  Util.swift
//  RepoViewer
//
//  Created by vas on 10.10.2020.
//

import SwiftUI

extension Date{
    static var today: Date{
        let now = Date()
        let components = Calendar.current.dateComponents([.day, .month, .year], from: now)
        return Calendar.current.date(from: components)!
    }
}



struct VectorImageView: UIViewRepresentable {
  var name: String

  func makeUIView(context: Context) -> UIImageView {
    let imageView = UIImageView()
    imageView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)
    return imageView
  }

  func updateUIView(_ uiView: UIImageView, context: Context) {
    uiView.contentMode = .scaleAspectFit
    if let image = UIImage(named: name) {
      uiView.image = image
    }
  }
}

struct AdditionalLogicNavLink<Content: View, Label: View>: View {
    @State var isActive = false
    
    init(destination: Content, label: @escaping () -> Label, action: @escaping () -> Void) {
        self.destination = destination
        self.label = label
        self.action = action
    }
    
    let destination: Content
    let label: () -> Label
    let action: () -> Void
    
    var body: some View{
        Button(
            action: {
                action()
                isActive = true
            })
        {
            label()
        }
        .buttonStyle(PlainButtonStyle())
        .overlay(NavigationLink(destination: destination, isActive: $isActive, label: {EmptyView()}))
    }
}



func closeKeyboard(){
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
}


extension URLSession{
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?){
        
        var rData: Data?
        var rResponse: URLResponse?
        var rError: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        self.dataTask(with: url){data, response, error in
            rData = data
            rResponse = response
            rError = error
            
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (rData, rResponse, rError)
        

    }
}


