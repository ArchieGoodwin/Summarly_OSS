//
//  ChatListItemView.swift
//  Summarly
//
//  Created by Sergey Dikarev on 09.03.2023.
//

import SwiftUI

struct ChatListItemView: View {
    @State var chat: ChatModel
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(chat.date, style: .date)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Text(chat.date, style: .time)
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Spacer()
                }
                Text(shownLink())
                    .font(.body)
                    .foregroundColor(.teal)
                Text(shownMessage())
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            
            Image(systemName: "arrow.forward")
                .foregroundColor(.accentColor)
        }
        
    }
    
    func shownMessage() -> String {
        let mySubstring = chat.summary?[0..<100] // Hello
        return "\(mySubstring!)..."
       
    }
    
    func shownLink() -> String {
        let mySubstring = chat.link?[0..<100] // Hello
        return "\(mySubstring!)..."
       
    }
    
}

