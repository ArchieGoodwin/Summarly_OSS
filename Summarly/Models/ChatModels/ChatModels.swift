//
//  ChatModels.swift
//  strAI
//
//  Created by Sergey Dikarev on 05.03.2023.
//

import Foundation


public struct Message: Codable {
    let role: String
    let content: String
}

public struct ChatRequest: Codable {
    let model: String
    let messages: [Message]
}


public struct ChatResponse: Codable {
    let id: String
    let object: String
    let model: String
    let usage: TokenUsage
    let choices: [ChoiceObj]
}

struct TokenUsage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
    
}


struct ChoiceObj: Codable {
    let message: ChoiceMessage
}

struct ChoiceMessage: Codable {
    let role: String
    let content: String
    let finish_reason: String?
    let index: Int?

}
