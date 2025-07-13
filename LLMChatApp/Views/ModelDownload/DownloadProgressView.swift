//
//  DownloadProgressView.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import SwiftUI

struct DownloadProgressView: View {
    let progress: Double
    
    var body: some View {
        VStack {
            Text("Downloading Model...")
                .font(.headline)
            
            ProgressView(value: progress)
                .progressViewStyle(.linear)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
