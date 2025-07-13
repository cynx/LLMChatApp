//
//  LLMLocalModelStorage.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//

import Foundation
import SpeziLLM
import SpeziLLMLocal

/// Manages local storage of LLM models
class LLMLocalModelStorage {
    static let shared = LLMLocalModelStorage()
    
    private init() {}
    
    /// Check if a model exists locally
    func hasModel(_ type: LLMLocalSchema) -> Bool {
        // This checks if the model files exist in the app's documents directory
        let modelURL = getModelURL(for: type)
        return FileManager.default.fileExists(atPath: modelURL.path)
    }
    
    /// Get the URL for a model's storage location
    private func getModelURL(for type: LLMLocalSchema) -> URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        return documentsPath.appendingPathComponent("Models/\(type)")
    }
    
    /// Remove a model from storage
    func removeModel(_ type: LLMLocalSchema) throws {
        let modelURL = getModelURL(for: type)
        if FileManager.default.fileExists(atPath: modelURL.path) {
            try FileManager.default.removeItem(at: modelURL)
        }
    }
}

// Note: Model identifiers are now handled as strings directly in LLMLocalSchema 
