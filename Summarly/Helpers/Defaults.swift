//
//  Defaults.swift
//  Strai
//
//  Created by Sergey Dikarev on 26.12.2022.
//

import Foundation
import SwiftUI

func Localize(_ key: String) -> String {
    return NSLocalizedString(key, comment: "")
}

func Localize(_ key: String, _ arguments: CVarArg...) -> String {
    return String(format: Localize(key), arguments)
}

func saveDefaults(key: String, value: String?)
{
    UserDefaults.standard.set(value, forKey: key)
}

func getDefaults(key: String) -> String?
{
    return UserDefaults.standard.string(forKey: key)
}

extension String {
    func localize(_ arguments: CVarArg ...) -> String {
        String(format: Localize(self), arguments)
    }
}

// MARK: Log method

func Log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        print(items, separator: separator, terminator: terminator)
    #endif
}

let PineconeAPI_KEY = ""
let pinecone_api_baseurl = "https://someindex.pinecone.io"

// MARK: - Notifications names

extension View {
    func border(_ color: Color, width: CGFloat, cornerRadius: CGFloat) -> some View {
        overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(color, lineWidth: width))
    }
}
