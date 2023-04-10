//
//  SummarlyTextField.swift
//  Summarly
//
//  Created by Sergey Dikarev on 07.03.2023.
//

import SwiftUI

struct SummarlyTextField: View {
    @EnvironmentObject var model: ContentViewModel
    @State private var array = ["arrow.up.circle.fill", "arrow.right.circle.fill", "arrow.down.circle.fill", "arrow.left.circle.fill"]
    @State private var text = ""
    @State private var index: Int = 0
    var action: (String) -> Void
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                TextField(model.currentChat == nil ? "Link to text/article/PDF or Paste text" : "Type your question per article/text", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                Button {
                    action(text)
                    text = ""
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .padding(.trailing)
                  
                }
                .disabled(model.working)

            }
            Spacer()
        }
        .background(Color.mint.edgesIgnoringSafeArea(.bottom))
        .onChange(of: model.currentChat) { newValue in
            Log("Model changed", newValue)
        }

    }
    
    func calculateIndex() -> Int {
        if index == 3 {
            return 0
        }
        return index + 1
    }
}

struct SummarlyTextField_Previews: PreviewProvider {
    static var previews: some View {
        SummarlyTextField(action: { text in
            
        }).environmentObject(generateModel())
    }
    
    static func generateModel() -> ContentViewModel
    {
        let m = ContentViewModel()
        return m
    }
}
