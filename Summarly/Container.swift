//
//  Container.swift
//  Summarly
//
//  Created by Sergey Dikarev on 09.03.2023.
//

import SwiftUI

struct Container: View {
    @EnvironmentObject var model: ContentViewModel

    var body: some View {
        let index = model.navigationIndex
        
        switch model.navigationStack[index] {
            case "ContentView":
                ContentView().environmentObject(model)
            case "ChatsListView":
                ChatsListView().environmentObject(model)
            default:
                ChatsListView().environmentObject(model)
        }
    }
}

struct Container_Previews: PreviewProvider {
    static var previews: some View {
        Container().environmentObject(generateModel())
    }
    
    static func generateModel() -> ContentViewModel
    {
        let m = ContentViewModel()
        return m
    }
}
