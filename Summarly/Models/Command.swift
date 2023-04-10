//
//  Command.swift
//  strAI
//
//  Created by Sergey Dikarev on 10.12.2022.
//

import Foundation

class CommandText: Encodable {
    var prompt: String
    var model: String
    var maxTokens: Int
    
    init(prompt: String, model: String, maxTokens: Int) {
        self.prompt = prompt
        self.model = model
        self.maxTokens = maxTokens
    }
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case model
        case maxTokens = "max_tokens"
    }
}

class CommandImage: Encodable {
    var prompt: String
    var n: Int
    var size: String
    var responseFormat: String
    var user: String?
    
    init(prompt: String, number: Int, size: ResponseAIImageSize, format: ResponseImageFormat, user: String?) {
        self.prompt = prompt
        self.n = number
        self.size = size.rawValue
        self.responseFormat = format.rawValue
        self.user = user
    }
    
    enum CodingKeys: String, CodingKey {
        case prompt
        case n
        case responseFormat = "response_format"
        case size
        case user
    }
}
