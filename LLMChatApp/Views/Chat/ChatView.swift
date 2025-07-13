//
//  ChatView.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import SwiftUI
import SpeziLLM
import SpeziLLMLocal

struct ChatView: View {
    @EnvironmentObject var modelManager: ModelManager
    @Environment(LLMRunner.self) var runner
    @StateObject private var chatSession = ChatSession()
    @State private var messageText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if modelManager.selectedModel == nil {
                    NoModelSelectedView()
                } else {
                    // Alternative: Use the built-in LLMChatView
                    if let model = modelManager.selectedModel,
                       let schema = createSchema(for: model) {
                        LLMChatView(schema: schema)
                    } else {
                        // Fallback to custom chat implementation
                        ChatMessagesView(messages: chatSession.messages)
                        
                        if chatSession.isGenerating {
                            ProgressView()
                                .padding()
                        }
                        
                        MessageInputView(messageText: $messageText) {
                            sendMessage()
                        }
                        .disabled(chatSession.isGenerating)
                    }
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let model = modelManager.selectedModel {
                        Text(model.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let userMessage = ChatMessage(content: messageText, isUser: true)
        chatSession.messages.append(userMessage)
        
        let prompt = messageText
        messageText = ""
        
        Task {
            await generateResponse(prompt: prompt)
        }
    }
    
    func generateResponse(prompt: String) async {
        guard let model = modelManager.selectedModel,
              let schema = createSchema(for: model) else { return }
        
        chatSession.isGenerating = true
        
        do {
            // Create session via LLMRunner
            let session: LLMLocalSession = runner(with: schema)
            
            // Send prompt and collect response
            try await session.send(prompt: prompt)
            
            var fullResponse = ""
            for try await token in try await session.generate() {
                fullResponse.append(token)
                
                // Update UI with streaming response
                await MainActor.run {
                    if chatSession.messages.last?.isUser == false {
                        // Update existing assistant message
                        chatSession.messages[chatSession.messages.count - 1] = ChatMessage(
                            content: fullResponse,
                            isUser: false
                        )
                    } else {
                        // Add new assistant message
                        chatSession.messages.append(ChatMessage(
                            content: fullResponse,
                            isUser: false
                        ))
                    }
                }
            }
        } catch {
            await MainActor.run {
                chatSession.messages.append(ChatMessage(
                    content: "Error: \(error.localizedDescription)",
                    isUser: false
                ))
            }
        }
        
        chatSession.isGenerating = false
    }
    
    /// Create appropriate schema for the model
    private func createSchema(for model: LLMLocalModel) -> LLMLocalSchema? {
        switch model.id {
        case "llama-3.2-1b":
            return LLMLocalSchema(
                model: .llama3_2_1B_4bit,
                parameters: .init(
                    systemPrompt: "You are a helpful assistant. Provide clear and concise responses.",
                    maxOutputLength: 512,
                   // temperature: 0.7,
                )
            )
        case "phi-3-mini":
            return LLMLocalSchema(
                model: .phi3_5_4bit,
                parameters: .init(
                    systemPrompt: "You are a helpful assistant. Provide clear and concise responses.",
                    maxOutputLength: 512,
                   // temperature: 0.7,
                )
            )
        case "mistral-7b-q4":
            return LLMLocalSchema(
                model: .mistral7B4bit,
                parameters: .init(
                    systemPrompt: "You are a helpful assistant. Provide clear and concise responses.",
                    maxOutputLength: 512,
                   // temperature: 0.7,
                )
            )
        default:
            return nil
        }
    }
}
