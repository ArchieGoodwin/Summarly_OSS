//
//  Messages.swift
//  Summarly
//
//  Created by Sergey Dikarev on 08.03.2023.
//

import Foundation
import SwiftUI

struct ChatMessage: Identifiable, Codable {
    let id: UUID = UUID()
    let isUser: Bool
    let tag: String
    let header: String
    let message: String
    let messageImage: String?
    let actionImage: String?
}
