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
    @GestureState var isDragging: Bool = false
    
    let threshold: CGFloat = 0.5
    let user: User
    let index: Int
    let onRemove: ((Int) -> Void)?
    
    var body: some View {
        let dragGesture = DragGesture()
            .updating($translation) { (value, state, _) in
                state = value.translation
            }
            .updating($degrees) { (value, state, _) in
                state = value.translation.width > 0 ? 2 : -2
            }
            .updating($isDragging) { (value, state, _) in
                state = value.translation.width != 0
            }
            .onEnded { (value) in
                let dragPercentage = value.translation.width / proxy.size.width
                
                if abs(dragPercentage) > threshold {
                    // remove the card
                    onRemove?(index)
                }

            }

        Rectangle()
            .overlay(
                GeometryReader { proxy in
                    ZStack {
                        Image(user.image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipped()
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                            Text("\(user.distance)Km away")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        
                        }
                        .position(
                            x: proxy.frame(in: .local).minX + 75,
                            y: proxy.frame(in: .local).maxY - 50
                        )
                        
                        Rectangle()
                            .overlay(Text("👎"))
                            .foregroundColor(.red)
                            .opacity(degrees < 0 ? 1 : 0)
                            .frame(width: 50, height: 50)
                            .cornerRadius(25)
                            .position(
                                x: proxy.frame(in: .local).midX - 50,
                                y: proxy.frame(in: .local).midY
                            )
                            .scaleEffect(isDragging ? 2 : 1)
                            .animation(.default)
                        
                        Rectangle()
                            .overlay(Text("♥️"))
                            .foregroundColor(.green)
                            .opacity(degrees > 0 ? 1 : 0)
                            .frame(width: 50, height: 50)
                            .cornerRadius(25)
                            .position(
                                x: proxy.frame(in: .local).midX + 50,
                                y: proxy.frame(in: .local).midY
                            )
                            .scaleEffect(isDragging ? 2 : 1)
                            .animation(.default)

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
            .scaleEffect(user.isBehind ? 0.95 : 1)
            .gesture(dragGesture)
            .animation(.interactiveSpring())
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            CardView(proxy: proxy, user: User.users[0], index: 0, onRemove: nil)
        }
    }
}