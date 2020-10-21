//
//  SwiftUIView.swift
//  RepoViewer
//
//  Created by vas on 17.10.2020.
//

import SwiftUI
import SVGKit
import SwiftyGif

struct ItemImageView: View {
    
    let item: SearchItem
    let geo: GeometryProxy
    let scaleCoef: CGFloat?
    let innerWidth: CGFloat
    
    init(item: SearchItem, geo: GeometryProxy) {
        self.item = item
        self.geo = geo
        self.innerWidth = geo.size.width * 0.8
        if let imageSize = item.imageSize{
            scaleCoef = innerWidth / imageSize.width
        } else {
            scaleCoef = nil
        }
       
    }
    
    var body: some View {
        if item.imageType == .otherType{
            let image = item.imageData! as! UIImage
            if image.size.width < innerWidth{
                Image(uiImage: image)
            } else {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: innerWidth)
            }
        }
        
        if item.imageType == .svg{
            let svgImage = item.imageData! as! SVGKImage
            let height = item.imageSize!.height * scaleCoef!
            SVGView(image: svgImage, width: innerWidth, height: height)
        }
        
        if item.imageType == .gif{
            let gifImage = item.imageData! as! UIImage
            let width = item.imageSize!.width < innerWidth ?
                item.imageSize!.width :
                item.imageSize!.width * scaleCoef!
            let height = item.imageSize!.width < innerWidth ?
                item.imageSize!.height :
                item.imageSize!.height * scaleCoef!
            GifView(gifImage: gifImage, width: width, height: height)
                .frame(width: width, height: height)
        }
    }
}


struct GifView: UIViewRepresentable{

    let gifImage: UIImage
    let width: CGFloat
    let height: CGFloat

    func makeUIView(context: Context) -> UIView {
        let imageView = UIImageView(gifImage: gifImage)
        imageView.frame = .init(origin: .zero, size: CGSize(width: width, height: height))
        imageView.contentMode = .scaleAspectFit
        let view = UIView(frame: .init(origin: .zero, size: CGSize(width: width, height: height)))
        view.addSubview(imageView)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
}


struct SVGView:UIViewRepresentable {
    
    let image: SVGKImage
    let width: CGFloat
    let height: CGFloat
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        SVGKFastImageView(svgkImage: image)
    }
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        uiView.image.size = CGSize(width: width, height: height)
    }
}
