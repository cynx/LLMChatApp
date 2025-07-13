//
//  NoModelSelectedView.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import SwiftUI

struct NoModelSelectedView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "cpu")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Model Selected")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Please download and select a model from the Models tab to start chatting.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
