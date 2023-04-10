//
//  LoadingView.swift
//  Summarly
//
//  Created by Sergey Dikarev on 09.03.2023.
//

import SwiftUI

struct LoadingDots: View {
    @State private var loadingFirstDot: Bool = false
    @State private var loadingSecondDot: Bool = false
    @State private var loadingThirdDot: Bool = false

    let reloadScreen = Timer.publish(every: 2, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            HStack(spacing: 3) {
                
                HStack(spacing: 5) {
                    Rectangle()
                        .foregroundColor(.teal)
                        .frame(width: 7, height: 7)
                        .offset(y: 9)
                        .opacity(loadingFirstDot ? 1 : 0)
                    
                    Rectangle()
                        .foregroundColor(.teal)
                        .frame(width: 7, height: 7)
                        .offset(y: 9)
                        .opacity(loadingSecondDot ? 1 : 0)
                       
                    Rectangle()
                        .foregroundColor(.teal)
                        .frame(width: 7, height: 7)
                        .offset(y: 9)
                        .opacity(loadingThirdDot ? 1 : 0)
                }
                .padding()
            }
            .border(.indigo.opacity(0.1), width: 1, cornerRadius: 12)
        }
        .onReceive(reloadScreen, perform: { _ in
            loadingTheDots()
        })
        .onAppear {
            loadingTheDots()
        }
    }
    
    func loadingTheDots() {
        withAnimation(.linear(duration: 0.5)) {
            loadingFirstDot = true
        }

        withAnimation(.linear(duration: 0.5).delay(0.5)) {
            loadingSecondDot = true
        }

        withAnimation(.linear(duration: 0.5).delay(1)) {
            loadingThirdDot = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            loadingFirstDot = false
            loadingSecondDot = false
            loadingThirdDot = false
        }
    }
}

struct LoadingDots_Previews: PreviewProvider {
    static var previews: some View {
        LoadingDots()
    }
}
