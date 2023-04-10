//
//  ChatMessageView.swift
//  Summarly
//
//  Created by Sergey Dikarev on 08.03.2023.
//

import SwiftUI

struct ChatMessageView: View {
    let radius: CGFloat = 12
    let messageLimit: Int = 100

    @State var message: ChatMessage
    @State private var expanded: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
           
            if message.tag == "loading" {
                LoadingDots()
            }
            else {
                HStack(spacing: 0) {
                    if let image = message.messageImage {
                        Image(systemName: image).padding(.leading)
                    }
                    VStack(alignment: message.isUser ? .trailing : .leading, spacing: 0) {

                        Text(message.header)
                           .font(.headline)
                           .foregroundColor(.gray)
                           .padding(.top, 10)
                           .padding(message.isUser ? .trailing : .leading)
                        Text(shownMessage())
                            .multilineTextAlignment(message.isUser ? .trailing : .leading)
                            .padding(.top, 7)
                            .padding(.leading)
                            .padding(.trailing)
                            .padding(.bottom)
                        HStack {
                            if showExpandControl() || showCollapseControl() {
                                Image(systemName: expanded ? "arrow.down.and.line.horizontal.and.arrow.up" : "arrow.up.and.line.horizontal.and.arrow.down")
                                    .padding(.leading)
                                    .padding(.bottom)
                                    .onTapGesture {
                                        expanded.toggle()
                                    }
                            }
                            Spacer()
                            if let image = message.actionImage {
                                
                                ShareLink(item: message.message) {
                                    Image(systemName: image)
                                }
                                .foregroundColor(.accentColor)
                                .padding(.trailing)
                                .padding(.bottom)
                                   
                            }
                        }
                       
                    }
                    
                }
                .background(
                    Rectangle()
                        .foregroundColor(message.isUser ? Color.indigo.opacity(0.2) : Color.teal.opacity(0.2))
                        .cornerRadius(radius: 12, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                )
             
            }
            

        }
     

       
    }
    
    func showExpandControl() -> Bool {
        if expanded {
            return false
        }
        else {
            return message.message.count > messageLimit
        }
       
    }
    
    func showCollapseControl() -> Bool {
       return expanded
       
    }
    
    func shownMessage() -> String {
        if expanded {
            return message.message
        }
        else {
            if message.message.count > messageLimit {
                let mySubstring = message.message[0..<messageLimit] // Hello
                return "\(mySubstring)..."
            }
            return message.message
        }
       
    }
   
}

struct ChatMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessageView(message: generateMessage())
    }
    
    static func generateMessage() -> ChatMessage {
        let message = ChatMessage(isUser: false, tag: "system", header: "Summary", message: "There is some message fjdsnaf jdsanjfndsa  nfksdkafkdsamfdsafd dsan dsadsaldn sdsamd ksamd msakldm lksamdklsamd sad sa", messageImage: nil, actionImage: "square.and.arrow.up.on.square")
        return message
    }
}


struct CornerRadiusShape: Shape {
    var radius = CGFloat.infinity
    var corners = UIRectCorner.allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


struct CornerRadiusStyle: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func body(content: Content) -> some View {
        content
            .clipShape(CornerRadiusShape(radius: radius, corners: corners))
    }
}

extension View {
    func cornerRadius(radius: CGFloat, corners: UIRectCorner) -> some View {
        ModifiedContent(content: self, modifier: CornerRadiusStyle(radius: radius, corners: corners))
    }
}


extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}
