//
//  ModelDownloadView.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import SwiftUI
import Combine

struct ModelDownloadView: View {
    @EnvironmentObject var modelManager: ModelManager
    @State private var searchText = ""
    
    var filteredModels: [LLMLocalModel] {
        if searchText.isEmpty {
            return modelManager.availableModels
        } else {
            return modelManager.availableModels.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if modelManager.isDownloading {
                    DownloadProgressView(progress: modelManager.downloadProgress)
                        .padding()
                }
                
                List {
                    Section("Available Models") {
                        ForEach(filteredModels) { model in
                            ModelRowView(model: model, isDownloaded: false)
                        }
                    }
                    
                    Section("Downloaded Models") {
                        ForEach(modelManager.downloadedModels) { model in
                            ModelRowView(model: model, isDownloaded: true)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search models...")
            }
            .navigationTitle("Model Library")
        }
    }
}
