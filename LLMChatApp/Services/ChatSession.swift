//
//  ChatSession.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import Foundation
import SwiftUI
import Combine
import SpeziLLM
import SpeziLLMLocal

class ChatSession: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating = false
    
    /// Generate response using the provided LLMRunner
    func generateResponse(prompt: String, model: LLMLocalModel, runner: LLMRunner) async {
        await MainActor.run {
            self.isGenerating = true
        }
        
        do {
            // Create schema for the model
            let schema = LLMLocalRunner.createSchema(for: model)
            
            // Create a new session via LLMRunner - THIS IS THE CORRECT WAY!
            let session: LLMLocalSession = runner(with: schema)
            
            // Send the prompt
      //      try await session.send(prompt: prompt)
            
            // Stream the response
            var fullResponse = ""
            for try await token in try await session.generate() {
                fullResponse.append(token)
                
                // Update UI with partial response for real-time streaming
                await MainActor.run {
                    if let lastMessage = self.messages.last, !lastMessage.isUser {
                        // Update existing assistant message
                        self.messages[self.messages.count - 1] = ChatMessage(
                            content: fullResponse,
                            isUser: false
                        )
                    } else {
                        // Add new assistant message
                        self.messages.append(ChatMessage(content: fullResponse, isUser: false))
                    }
                }
            }
            
            await MainActor.run {
                self.isGenerating = false
            }
            
        } catch {
            await MainActor.run {
                self.messages.append(ChatMessage(
                    content: "Error: \(error.localizedDescription)",
                    isUser: false
                ))
                self.isGenerating = false
            }
        }
    }
    
    /// Clear chat history
    func clearMessages() {
        messages.removeAll()
    }
}
