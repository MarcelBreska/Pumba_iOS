//
//  ProgressView.swift
//  Pumba
//
//  Created by Marcel Breska on 22.06.23.
//

import SwiftUI
import UIKit

struct ProgressView: View {
    var color: Color
    var icon: String
    var maxValue: CGFloat
    var value: CGFloat
    var text: String
    
    var progress: CGFloat {
        if maxValue == 0 { return 0 }
        
        return value / maxValue
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.gray)
                    Rectangle()
                        .fill(color)
                        .frame(height: min(geo.size.height, geo.size.height * progress))
                }.cornerRadius(15.0)
            }
            VStack {
                Image(systemName: icon)
                    .font(.title3.bold())
                Text(text)
                    .font(.body.bold())
                    .padding(.top, 2)
            }
            .foregroundColor(.white)
        }
        .animation(.easeInOut, value: progress)
        .animation(.easeInOut, value: icon)
//        .onTapGesture {
//            value = CGFloat.random(in: 0...maxValue)
//        }
    }
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(color: .green, icon: "battery.100", maxValue: 100, value: 83, text: "83%")
            .frame(width: 100, height: 200)
    }
}
