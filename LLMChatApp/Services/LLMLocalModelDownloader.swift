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
class LLMLocalModelDownloader: ObservableObject {
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloading = false
    
    /// Get list of already downloaded models
    func getDownloadedModels() -> [LLMLocalModel] {
        // Check which models are available locally
        var downloadedModels: [LLMLocalModel] = []
        
        // Check each known model
        let knownModels = [
            (id: "llama-3.2-1b", name: "Llama 3.2 1B", size: "1.2GB", type: LLMLocalModelType.llama3_2_1B_4bit),
            (id: "phi-3-mini", name: "Phi-3.5 Mini", size: "2.8GB", type: LLMLocalModelType.phi3_5_mini_4bit),
            (id: "mistral-7b-q4", name: "Mistral 7B Q4", size: "3.8GB", type: LLMLocalModelType.mistral7B_4bit)
        ]
        
        for model in knownModels {
            if LLMLocalModelStorage.shared.hasModel(model.type) {
                downloadedModels.append(
                    LLMLocalModel(id: model.id, name: model.name, size: model.size)
                )
            }
        }
        
        return downloadedModels
    }
    
    /// Download a model - Note: In real implementation, use LLMLocalDownloadView
    func download(_ model: LLMLocalModel, progressHandler: @escaping (Double) -> Void) async throws {
        // This is a simplified version - in production, use LLMLocalDownloadView
        // which provides proper download UI and progress tracking
        
        isDownloading = true
        downloadProgress = 0.0
        
        // Simulate download for demonstration
        // In real app, LLMLocalDownloadView handles this
        for i in 0...10 {
            try await Task.sleep(nanoseconds: 500_000_000)
            let progress = Double(i) / 10.0
            
            await MainActor.run {
                self.downloadProgress = progress
                progressHandler(progress)
            }
        }
        
        await MainActor.run {
            self.isDownloading = false
            self.downloadProgress = 1.0
        }
    }
    
    /// Delete a model from storage
    func deleteModel(_ model: LLMLocalModel) {
        guard let modelType = mapLocalModelToSpeziModel(model) else { return }
        
        do {
            try LLMLocalModelStorage.shared.removeModel(modelType)
            print("Successfully deleted model: \(model.name)")
        } catch {
            print("Failed to delete model: \(error)")
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
}

// MARK: - Model Storage Extension
extension LLMLocalModelStorage {
    static let shared = LLMLocalModelStorage()
    
    /// Check if a model exists locally
    func hasModel(_ type: LLMLocalModelType) -> Bool {
        // This checks if the model files exist in the app's documents directory
        let modelURL = getModelURL(for: type)
        return FileManager.default.fileExists(atPath: modelURL.path)
    }
    
    /// Get the URL for a model's storage location
    private func getModelURL(for type: LLMLocalModelType) -> URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        return documentsPath.appendingPathComponent("Models/\(type.modelIdentifier)")
    }
    
    /// Remove a model from storage
    func removeModel(_ type: LLMLocalModelType) throws {
        let modelURL = getModelURL(for: type)
        if FileManager.default.fileExists(atPath: modelURL.path) {
            try FileManager.default.removeItem(at: modelURL)
        }
    }
}

// Extension to get model identifier
extension LLMLocalModelType {
    var modelIdentifier: String {
        switch self {
        case .llama3_2_1B_4bit: return "llama3_2_1b_4bit"
        case .phi3_5_mini_4bit: return "phi3_5_mini_4bit"
        case .mistral7B_4bit: return "mistral7b_4bit"
        default: return "unknown"
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
