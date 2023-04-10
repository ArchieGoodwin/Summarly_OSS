//
//  ChatModel.swift
//  Summarly
//
//  Created by Sergey Dikarev on 07.03.2023.
//

import Foundation


class ChatModel: Equatable, Identifiable, Codable {
    let id: String = UUID().uuidString
    static func == (lhs: ChatModel, rhs: ChatModel) -> Bool {
        return lhs.link == rhs.link &&
        lhs.date == rhs.date
    }
    
    var link: String? = nil
    var text: String? = nil
    var file: String? = nil
    var summary: String? = nil
    var results: [String] = []
    var response: ChatResponse? = nil
    var date: Date = Date()
    var messages: [ChatMessage] = []

}
