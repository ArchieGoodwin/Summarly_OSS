//
//  AIEndpoint.swift
//  strAI
//
//  Created by Sergey Dikarev on 10.12.2022.
//

import Foundation

enum Endpoint {
    case completions
    case images
    case chatcompletions
    case embeddings
}

extension Endpoint {
    var path: String {
        switch self {
        case .completions:
            return "/v1/completions"
        case .chatcompletions:
                return "/v1/chat/completions"
        case .images:
            return "/v1/images/generations"
        case .embeddings:
            return "/v1/embeddings"
        }
    }
    
    var method: String {
        switch self {
        case .completions:
            return "POST"
        case .chatcompletions:
            return "POST"
        case .images:
            return "POST"
        case .embeddings:
            return "POST"
        }
    }
    
    func baseURL() -> String {
        switch self {
        case .completions:
            return "https://api.openai.com"
        case .chatcompletions:
            return "https://api.openai.com"
        case .images:
            return "https://api.openai.com"
        case .embeddings:
            return "https://api.openai.com"

        }
    }
}
