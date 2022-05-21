//
//  CardView.swift
//  iOSAppDev.Assign3
//
//  Created by Nicholas on 21/5/22.
//


import SwiftUI

struct CardView: View {
    let proxy: GeometryProxy
    @GestureState var translation: CGSize = .zero
    @GestureState var degrees: Double = 0
    
    var body: some View {
        let dragGesture = DragGesture()
            .updating($translation) { (value, state, _) in
                state = value.translation
            }
        //updates the degrees if the translation is +2 then swiping right if -2 then they are swiping left
            .updating($degrees) { (value, state, _) in
                state = value.translation.width > 0 ? 2 : -2
            }
            .onEnded { (value) in
                
            }

        Rectangle()
            .overlay(
                GeometryReader { proxy in
                    ZStack {
                        Image("Pizza")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                        VStack(alignment: .leading) {
                            Text("Pizza")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            Text("iOS Dev")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        
                        }
                        .position(
                            x: proxy.frame(in: .local).minX + 75,
                            y: proxy.frame(in: .local).maxY - 50
                        )
                    }
                }
            )
            .cornerRadius(10)
            .frame(
                maxWidth: proxy.size.width - 28,
                maxHeight: proxy.size.height * 0.8
            )
            .position(
                x: proxy.frame(in: .global).midX,
                y: proxy.frame(in: .local).midY - 30
            )
            .offset(x: translation.width, y: 0)
            .rotationEffect(.degrees(degrees))
            .gesture(dragGesture)
            .animation(.interactiveSpring())
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            CardView(proxy: proxy)
        }
    }
}
