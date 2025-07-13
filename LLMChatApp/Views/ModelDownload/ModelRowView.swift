//
//  ModelRowView.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import SwiftUI

struct ModelRowView: View {
    let model: LLMLocalModel
    let isDownloaded: Bool
    @EnvironmentObject var modelManager: ModelManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(model.name)
                    .font(.headline)
                Text(model.size)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isDownloaded {
                HStack {
                    if modelManager.selectedModel?.id == model.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    
                    Button(action: {
                        modelManager.selectModel(model)
                    }) {
                        Text("Use")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        modelManager.deleteModel(model)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                }
            } else {
                Button(action: {
                    Task {
                        await modelManager.downloadModel(model)
                    }
                }) {
                    Label("Download", systemImage: "arrow.down.circle")
                        .font(.caption)
                }
                .buttonStyle(.borderedProminent)
                .disabled(modelManager.isDownloading)
            }
        }
        .padding(.vertical, 4)
    }
}
