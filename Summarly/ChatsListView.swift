//
//  ChatsListView.swift
//  Summarly
//
//  Created by Sergey Dikarev on 08.03.2023.
//

import SwiftUI

struct ChatsListView: View {
    @EnvironmentObject var model: ContentViewModel

    var body: some View {
        VStack {
            Image("logo_s")
                
            if model.chats.isEmpty {
                NoChatsListView().environmentObject(model)
            }
            else {
                VStack {
                    List(model.chats.sorted(by: { chat1, chat2 in
                        return chat1.date > chat2.date
                    })) { chat in
                        ChatListItemView(chat: chat)
                            .listRowSeparator(.visible)
                            .onTapGesture {
                                model.currentChat = chat
                                model.messages = chat.messages
                                model.navigationIndex = 1
                            }
                            .swipeActions(content: {
                                Button("Delete chat") {
                                    if let index = model.chats.firstIndex(of: chat) {
                                        model.chats.remove(at: index)
                                        model.saveChats()
                                    }
                                    
                                }
                                .tint(.red)
                            })
                    }
                   
                    .listStyle(PlainListStyle())
                    
                    Spacer()
                    
                    Button {
                        model.messages = []
                        model.navigationIndex = 1
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.accentColor)
                            .imageScale(.large)
                            .overlay {
                                Rectangle().foregroundColor(.clear)
                                    .frame(width: 40, height: 40)
                            }
                    }
                }
                
            }
        }
        
        
    }
}

struct ChatsListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsListView().environmentObject(generateModel())
    }
    
    static func generateModel() -> ContentViewModel
    {
        let m = ContentViewModel()
        return m
    }
}
