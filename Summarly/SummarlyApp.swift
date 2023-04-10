//
//  SummarlyApp.swift
//  Summarly
//
//  Created by Sergey Dikarev on 07.03.2023.
//

import SwiftUI

@main
struct SummarlyApp: App {
    var body: some Scene {
        WindowGroup {
            Container().environmentObject(generateModel())
        }
    }
    
    func generateModel() -> ContentViewModel
    {
        let m = ContentViewModel()
        m.loadChats()
        return m
    }
}
