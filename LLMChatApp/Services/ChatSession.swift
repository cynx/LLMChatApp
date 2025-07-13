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
    
    private var currentSession: LLMLocalSession?
    @Environment(LLMRunner.self) private var runner
    
    func generateResponse(prompt: String, using model: LLMLocalModel?) async {
        guard let model = model else { return }
        
        DispatchQueue.main.async {
            self.isGenerating = true
        }
        
        do {
            // Create schema for the model
            let schema = createSchema(for: model)
            
            // Create a new session via LLMRunner
            let session: LLMLocalSession = LLMRunner.shared(with: schema)
            currentSession = session
            
            // Send the prompt
            try await session.send(prompt: prompt)
            
            // Stream the response
            var fullResponse = ""
            for try await token in try await session.generate() {
                fullResponse.append(token)
                
                // Update UI with partial response for real-time streaming
                DispatchQueue.main.async {
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
            
            DispatchQueue.main.async {
                self.isGenerating = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.messages.append(ChatMessage(
                    content: "Error: \(error.localizedDescription)",
                    isUser: false
                ))
                self.isGenerating = false
            }
        }
    }
    
    /// Create appropriate schema for the model
    private func createSchema(for model: LLMLocalModel) -> LLMLocalSchema {
        // Map model IDs to actual model configurations
        switch model.id {
        case "llama-3.2-1b":
            return LLMLocalSchema(
                model: .llama3_2_1B_4bit,
                parameters: .init(
                    maxOutputLength: 512,
                  //  temperature: 0.7,
                    systemPrompt: "You are a helpful assistant. Provide clear and concise responses."
                )
            )
        case "phi-3-mini":
            return LLMLocalSchema(
                model: .phi3_5_mini_4bit,
                parameters: .init(
                    maxOutputLength: 512,
                 //   temperature: 0.7,
                    systemPrompt: "You are a helpful assistant. Provide clear and concise responses."
                )
            )
        case "mistral-7b-q4":
            return LLMLocalSchema(
                model: .mistral7B_4bit,
                parameters: .init(
                    maxOutputLength: 512,
                   // temperature: 0.7,
                    systemPrompt: "You are a helpful assistant. Provide clear and concise responses."
                )
            )
        default:
            // Default to Llama 3.2 1B if model not recognized
            return LLMLocalSchema(
                model: .llama3_2_1B_4bit,
                parameters: .init(
                    maxOutputLength: 512,
                   // temperature: 0.7,
                    systemPrompt: "You are a helpful assistant. Provide clear and concise responses."
                )
            )
        }
    }
    
    /// Clear chat history
    func clearMessages() {
        messages.removeAll()
        currentSession = nil
    }
}
