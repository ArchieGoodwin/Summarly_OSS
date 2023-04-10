//
//  OpenAI.swift
//  strAI
//
//  Created by Sergey Dikarev on 10.12.2022.
//

import Foundation

public struct OpenAI: Codable {
    public let object: String
    public let model: String
    public let choices: [Choice]
}

public struct Choice: Codable {
    public let text: String
}


public struct AIImageResponse: Codable {
    public let created: Int
    public let data: [ImageResult]
}


public struct ImageResult: Codable {
    public let url: String
}
