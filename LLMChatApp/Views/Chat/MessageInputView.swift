//
//  MessageInputView.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import SwiftUI

struct MessageInputView: View {
    @Binding var messageText: String
    let onSend: () -> Void
    
    var body: some View {
        HStack {
            TextField("Type a message...", text: $messageText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSend()
                }
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
            }
            .disabled(messageText.isEmpty)
        }
        .padding()
    }
}
