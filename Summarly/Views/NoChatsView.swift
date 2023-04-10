//
//  NoChatsView.swift
//  Summarly
//
//  Created by Sergey Dikarev on 07.03.2023.
//

import SwiftUI

struct NoChatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.fill").foregroundColor(.mint)
            Text("Paste link of article or paste text in textfield below to start new Summarly")
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.leading)
                .padding(.trailing)
        }
    }
}

struct NoChatsView_Previews: PreviewProvider {
    static var previews: some View {
        NoChatsView()
    }
}
