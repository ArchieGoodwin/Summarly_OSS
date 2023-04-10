//
//  NoChatsView.swift
//  Summarly
//
//  Created by Sergey Dikarev on 07.03.2023.
//

import SwiftUI

struct NoChatsListView: View {
    
    @EnvironmentObject var model: ContentViewModel

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.fill").foregroundColor(.mint)
                .imageScale(.large)
            Text("There are no saved chats yet. Start new summarly chat with button below")
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.leading)
                .padding(.trailing)
            Button {
                model.navigationIndex = 1
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.accentColor)
            }

        }
    }
}

struct NoChatsListView_Previews: PreviewProvider {
    static var previews: some View {
        NoChatsView()
    }
}
