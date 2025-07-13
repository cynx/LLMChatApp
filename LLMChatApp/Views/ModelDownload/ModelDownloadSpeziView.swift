//
//  ModelDownloadSpeziView.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import SwiftUI
import SpeziLLMLocalDownload

/// Alternative implementation using SpeziLLM's built-in download view
struct ModelDownloadSpeziView: View {
    @EnvironmentObject var modelManager: ModelManager
    @State private var showingDownloadView = false
    @State private var selectedModelForDownload: LLMLocalModelType?
    
    var body: some View {
        NavigationView {
            List {
                Section("Available Models") {
                    ForEach(availableModels) { model in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(model.name)
                                    .font(.headline)
                                Text(model.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button("Download") {
                                selectedModelForDownload = model.speziModel
                                showingDownloadView = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                Section("Downloaded Models") {
                    if modelManager.downloadedModels.isEmpty {
                        Text("No models downloaded yet")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(modelManager.downloadedModels) { model in
                            ModelRowView(model: model, isDownloaded: true)
                        }
                    }
                }
            }
            .navigationTitle("Model Library")
            .sheet(item: $selectedModelForDownload) { modelType in
                NavigationView {
                    LLMLocalDownloadView(
                        model: modelType,
                        downloadDescription: "This model will be downloaded to your device for offline use."
                    ) {
                        // Refresh downloaded models after successful download
                        modelManager.loadDownloadedModels()
                        showingDownloadView = false
                    }
                    .navigationTitle("Download Model")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                showingDownloadView = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Define available models with their SpeziLLM types
    private var availableModels: [ModelInfo] {
        [
            ModelInfo(
                id: "llama-3.2-1b",
                name: "Llama 3.2 1B",
                description: "Compact model, ~1.2GB, good for basic tasks",
                speziModel: .llama3_2_1B_4bit
            ),
            ModelInfo(
                id: "phi-3-mini",
                name: "Phi-3.5 Mini",
                description: "Microsoft's efficient model, ~2.8GB",
                speziModel: .phi3_5_mini_4bit
            ),
            ModelInfo(
                id: "mistral-7b",
                name: "Mistral 7B",
                description: "Powerful open model, ~3.8GB",
                speziModel: .mistral7B_4bit
            ),
            ModelInfo(
                id: "llama-3-8b",
                name: "Llama 3 8B",
                description: "Latest Llama model, ~4.5GB",
                speziModel: .llama3_8B_4bit
            ),
            ModelInfo(
                id: "gemma-2b",
                name: "Gemma 2B",
                description: "Google's efficient model, ~1.5GB",
                speziModel: .gemma2B_4bit
            )
        ]
    }
}

// Helper struct for model information
private struct ModelInfo: Identifiable {
    let id: String
    let name: String
    let description: String
    let speziModel: LLMLocalModelType
}

// Extension to make LLMLocalModelType Identifiable for sheet presentation
extension LLMLocalModelType: Identifiable {
    public var id: String {
        switch self {
        case .llama3_2_1B_4bit: return "llama-3.2-1b"
        case .phi3_5_mini_4bit: return "phi-3-mini"
        case .mistral7B_4bit: return "mistral-7b"
        case .llama3_8B_4bit: return "llama-3-8b"
        case .gemma2B_4bit: return "gemma-2b"
        default: return "unknown"
        }
    }
}
