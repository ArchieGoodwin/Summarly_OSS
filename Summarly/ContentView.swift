//
//  ContentView.swift
//  Summarly
//
//  Created by Sergey Dikarev on 07.03.2023.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var model: ContentViewModel
    @State var showingExitAlert: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    if model.working {
                        showingExitAlert = true
                    }
                    else {
                        model.currentChat = nil
                        model.navigationIndex = 0
                    }
                } label: {
                    Image(systemName: "arrow.backward")
                        .foregroundColor(.accentColor)
                        .imageScale(.large)
                }
                .padding(.leading)
                .alert("Are you sure you want to exit chat? The current chat will be cancelled.", isPresented: $showingExitAlert) {
                    Button("Yes, I am sure", role: .destructive) {
                        showingExitAlert = false
                        model.working = false
                        model.currentChat = nil
                        model.navigationIndex = 0
                      
                    }
                    Button("Cancel", role: .cancel) {
                        showingExitAlert = false
                    }
                }
                Spacer()
            }
            .background(Color.clear)
            Spacer()
            if model.messages.isEmpty {
                NoChatsView()
                    .frame(maxHeight: .infinity)
            }
            else {
                ChatView().environmentObject(model)
            }
            Spacer()
            SummarlyTextField { text in
                Task { 
                    do {
                        if model.currentChat == nil {
                            try await model.generateChat(link: text)
                        }
                        else {
                            _ = try await model.startQueringEmbedding(question: text, namespace: model.currentChat!.link!)
                        }
                        
                    }
                    catch OpenAIError.incorrectUrl {
                        Log("incorrect url throw")
                    }
                    
                }
            }
            .environmentObject(model)
            .frame(height: 60)
        }
        .onAppear {
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(generateModel())
    }
    
    static func generateModel() -> ContentViewModel
    {
        let m = ContentViewModel()
        return m
    }
}
