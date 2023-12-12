//
//  Blur.swift
//  WeatherForecast
//
//  Created by Suguru Tokuda on 12/11/23.
//

import SwiftUI

class UIBackdropView: UIView {
    override class var layerClass: AnyClass {
        NSClassFromString("CABackdropLayer") ?? CALayer.self
    }
}

struct Backdrop<UIViewType: UIBackdropView>: UIViewRepresentable {
    func makeUIView(context: Context) -> UIBackdropView {
        UIBackdropView()
    }
    
    func updateUIView(_ uiView: UIBackdropView, context: Context) {
    }
}

struct Blur: View {
    var radius: CGFloat
    var opaque: Bool = false

    var body: some View {
        Backdrop()
            .blur(radius: radius, opaque: opaque)
    }
}

#Preview {
    Blur(radius: 25, opaque: true)
}
