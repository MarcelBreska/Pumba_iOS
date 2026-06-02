//
//  ButtonView.swift
//  Pumba
//
//  Created by Marcel Breska on 22.06.23.
//

import SwiftUI

struct RelayButton: View {
    let action: () -> Void
    @Binding var isOn: Bool

    let onIcon: String
    let offIcon: String
    let accentColor: Color
    
    var body: some View {
        Button {
            action()
            isOn.toggle()
        } label: {
            ZStack {
                Image(systemName: isOn ? onIcon : offIcon)
                    .animation(.easeInOut, value: isOn)
                    .accentColor(accentColor)
                    .font(.title3.bold())
                    .imageScale(.large)
                    .scaleEffect(isOn ? 0.95 : 1)
                    .animation(isOn ? .linear(duration: 0.5).repeatForever() : .default, value: isOn)
                    .glow(isGlowing: $isOn, radius: 3, color: .white)
                Color.clear
            }
        }
        .frame(width: 75, height: 75)
        .background(isOn ? Color.onButton : .gray)
        .animation(.easeInOut(duration: 0.1), value: isOn)
        .cornerRadius(20)
        .glow(isGlowing: $isOn, color: isOn ? Color.onButton : .gray)
    }
}

struct Glow: ViewModifier {
    @Binding var isGlowing: Bool
    var radius: CGFloat
    var color: Color
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isGlowing ? radius : 0)
                .scaleEffect(isGlowing ? 1.1 : 1.0)
                .animation(isGlowing ? .linear(duration: 0.5).repeatForever() : .default, value: isGlowing)
                .opacity(0.5)
                .zIndex(0)
            content
                .zIndex(1)
        }
    }
}

extension View {
    func glow(isGlowing: Binding<Bool>, radius: CGFloat = 10, color: Color) -> some View {
        modifier(Glow(isGlowing: isGlowing, radius: radius, color: color))
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        RelayButton(action: {}, isOn: .constant(true), onIcon: "bolt.fill", offIcon: "bolt.fill", accentColor: .yellow)
    }
}
