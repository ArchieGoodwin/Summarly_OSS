//
//  ChatView.swift
//  Summarly
//
//  Created by Sergey Dikarev on 08.03.2023.
//

import SwiftUI
import Foundation


struct ChatView: View {
    @EnvironmentObject var model: ContentViewModel

    var body: some View {
        List(model.messages) { message in
            ChatMessageView(message: message)
                .listRowSeparator(.hidden)
                .flippedUpsideDown()
           
        }
        .scrollDismissesKeyboard(.immediately)
        .listStyle(PlainListStyle())
        .flippedUpsideDown()
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView().environmentObject(generateModel())
    }
    
    static func generateModel() -> ContentViewModel
    {
        let m = ContentViewModel()
        
        let message = ChatMessage(isUser: true, tag: "system", header: "Your link", message: "There is some message", messageImage: nil, actionImage: nil)
        
        let message2 = ChatMessage(isUser: false, tag: "system", header: "Summary", message: "My answer may be rather long see if this is sutable dnksald kdasmk dmskam dsamd msakmd sakd msakmd ksamkd sa fdmksa fdsam fkdsmakf mdskam fkdlsm fkdksf ds", messageImage: nil, actionImage: "list.bullet.clipboard")
        m.messages = [message, message2]
        
        return m
    }
}


struct FlippedUpsideDown: ViewModifier {
   func body(content: Content) -> some View {
    content
           .rotationEffect(Angle.degrees(180))
      .scaleEffect(x: -1, y: 1, anchor: .center)
   }
}
extension View{
   func flippedUpsideDown() -> some View{
     self.modifier(FlippedUpsideDown())
   }
}
