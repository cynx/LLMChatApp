//
//  LLMLocalModelDownloader.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import Foundation
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMLocalDownload

/// Manages downloading and storage of local LLM models
class LLMLocalModelDownloader {
    private let modelStorage = LLMLocalModelStorage()
    
    /// Get list of already downloaded models
    func getDownloadedModels() -> [LLMLocalModel] {
        // Map SpeziLLM models to our LLMLocalModel type
        let downloadedModels = modelStorage.localModels()
        
        return downloadedModels.compactMap { speziModel in
            // Convert SpeziLLM model to our app's model representation
            mapSpeziModelToLocalModel(speziModel)
        }
    }
    
    /// Download a model from HuggingFace
    func download(_ model: LLMLocalModel, progressHandler: @escaping (Double) -> Void) async throws {
        // Map our model to SpeziLLM model type
        guard let speziModel = mapLocalModelToSpeziModel(model) else {
            throw DownloadError.unsupportedModel
        }
        
        // Create download manager
        let downloadManager = LLMLocalDownloadManager()
        
        // Start download with progress tracking
        let downloadTask = Task {
            for await progress in downloadManager.downloadProgress(for: speziModel) {
                progressHandler(progress.fractionCompleted)
            }
        }
        
        // Perform the actual download
        do {
            try await downloadManager.download(model: speziModel)
            downloadTask.cancel()
            progressHandler(1.0) // Ensure we show 100% completion
        } catch {
            downloadTask.cancel()
            throw DownloadError.downloadFailed(error.localizedDescription)
        }
    }
    
    /// Delete a model from storage
    func deleteModel(_ model: LLMLocalModel) {
        // Map to SpeziLLM model and delete
        if let speziModel = mapLocalModelToSpeziModel(model) {
            do {
                try modelStorage.deleteModel(speziModel)
                print("Successfully deleted model: \(model.name)")
            } catch {
                print("Failed to delete model: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Map our app's model representation to SpeziLLM models
    private func mapLocalModelToSpeziModel(_ model: LLMLocalModel) -> LLMLocalModelType? {
        switch model.id {
        case "llama-3.2-1b":
            return .llama3_2_1B_4bit
        case "phi-3-mini":
            return .phi3_5_mini_4bit
        case "mistral-7b-q4":
            return .mistral7B_4bit
        default:
            return nil
        }
    }
    
    /// Map SpeziLLM models to our app's model representation
    private func mapSpeziModelToLocalModel(_ speziModel: LLMLocalModelType) -> LLMLocalModel? {
        switch speziModel {
        case .llama3_2_1B_4bit:
            return LLMLocalModel(id: "llama-3.2-1b", name: "Llama 3.2 1B", size: "1.2GB")
        case .phi3_5_mini_4bit:
            return LLMLocalModel(id: "phi-3-mini", name: "Phi-3 Mini", size: "2.8GB")
        case .mistral7B_4bit:
            return LLMLocalModel(id: "mistral-7b-q4", name: "Mistral 7B Q4", size: "3.8GB")
        default:
            // Handle other models as needed
            return nil
        }
    }
}

// MARK: - Error Types
enum DownloadError: LocalizedError {
    case unsupportedModel
    case downloadFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .unsupportedModel:
            return "This model is not supported for download."
        case .downloadFailed(let reason):
            return "Download failed: \(reason)"
        }
    }
}
