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
    @State private var showBuiltInChat = false
    
    var body: some View {
        NavigationView {
            VStack {
                if modelManager.selectedModel == nil {
                    NoModelSelectedView()
                } else {
                    if showBuiltInChat {
                        // Use the built-in LLMChatView
                        if let model = modelManager.selectedModel {
                            LLMChatView(
                                with: LLMLocalRunner.createSchema(for: model)
                            )
                        }
                    } else {
                        // Custom chat implementation
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
                    if modelManager.selectedModel != nil {
                        Menu {
                            Button(action: { showBuiltInChat.toggle() }) {
                                Label(
                                    showBuiltInChat ? "Use Custom Chat" : "Use Built-in Chat",
                                    systemImage: showBuiltInChat ? "square.and.pencil" : "message"
                                )
                            }
                            
                            if !showBuiltInChat {
                                Button(action: { chatSession.clearMessages() }) {
                                    Label("Clear Chat", systemImage: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
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
        guard !messageText.isEmpty,
              let model = modelManager.selectedModel else { return }
        
        let userMessage = ChatMessage(content: messageText, isUser: true)
        chatSession.messages.append(userMessage)
        
        let prompt = messageText
        messageText = ""
        
        Task {
            // Pass the runner to generateResponse
            await chatSession.generateResponse(
                prompt: prompt,
                model: model,
                runner: runner
            )
        }
    }
}
