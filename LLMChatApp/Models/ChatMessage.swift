//
//  ChatMessage.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}
