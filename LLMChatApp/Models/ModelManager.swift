//
//  ModelManager.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import Foundation
import SwiftUI
import Combine

class ModelManager: ObservableObject {
    @Published var availableModels: [LLMLocalModel] = []
    @Published var downloadedModels: [LLMLocalModel] = []
    @Published var selectedModel: LLMLocalModel?
    @Published var isDownloading = false
    @Published var downloadProgress: Double = 0.0
    
    private let modelDownloader = LLMLocalModelDownloader()
    
    init() {
        loadAvailableModels()
        loadDownloadedModels()
    }
    
    func loadAvailableModels() {
        // Define available models
        availableModels = [
            LLMLocalModel(id: "llama-3.2-1b", name: "Llama 3.2 1B", size: "1.2GB"),
            LLMLocalModel(id: "phi-3-mini", name: "Phi-3.5 Mini", size: "2.8GB"),
            LLMLocalModel(id: "mistral-7b-q4", name: "Mistral 7B Q4", size: "3.8GB")
        ]
    }
    
    func loadDownloadedModels() {
        downloadedModels = modelDownloader.getDownloadedModels()
    }
    
    func downloadModel(_ model: LLMLocalModel) async {
        await MainActor.run {
            self.isDownloading = true
            self.downloadProgress = 0.0
        }
        
        do {
            try await modelDownloader.download(model) { progress in
                DispatchQueue.main.async {
                    self.downloadProgress = progress
                }
            }
            
            await MainActor.run {
                self.downloadedModels.append(model)
                self.isDownloading = false
            }
        } catch {
            print("Download failed: \(error)")
            await MainActor.run {
                self.isDownloading = false
            }
        }
    }
    
    func deleteModel(_ model: LLMLocalModel) {
        modelDownloader.deleteModel(model)
        downloadedModels.removeAll { $0.id == model.id }
        if selectedModel?.id == model.id {
            selectedModel = nil
        }
    }
    
    func selectModel(_ model: LLMLocalModel) {
        selectedModel = model
        // Model loading is handled by LLMRunner when creating sessions
        print("Selected model: \(model.name)")
    }
}
