//
//  LocalLLMRunner.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import Foundation
import SpeziLLM
import SpeziLLMLocal
import Combine

/// Manages local LLM execution using SpeziLLMLocal
class LLMLocalRunner {
    @Published private var currentSession: LLMLocalSession?
    private var currentModel: LLMLocalModel?
    
    /// Load a model and prepare it for inference
    func loadModel(_ model: LLMLocalModel) {
        print("Loading model: \(model.name)")
        currentModel = model
    }
    
    /// Generate a response using the loaded model
    func generate(prompt: String, model: LLMLocalModel) async throws -> String {
        guard currentModel?.id == model.id else {
            throw LLMError.modelNotLoaded
        }
        
        // Create LLM schema based on model ID
        let schema = createSchema(for: model)
        
        // Create a session using the schema
        let session = LLMLocalSession(<#LLMLocalPlatform#>, schema: schema)
        currentSession = session
        
        // Generate response
        var fullResponse = ""
        
        do {
            // Send the prompt to the session
            try await session.send(prompt: prompt)
            
            // Collect the streamed response
            for try await token in try await session.generate() {
                fullResponse.append(token)
            }
        } catch {
            throw LLMError.generationFailed(error.localizedDescription)
        }
        
        return fullResponse
    }
    
    /// Create appropriate schema for the model
    private func createSchema(for model: LLMLocalModel) -> LLMLocalSchema {
        // Map model IDs to actual model configurations
        switch model.id {
        case "llama-3.2-1b":
            return LLMLocalSchema(
                model: .llama3_2_1B_4bit,
                parameters: .init(
                    maxOutputLength: 512,
                   // temperature: 0.7
                )
            )
        case "phi-3-mini":
            return LLMLocalSchema(
                model: .phi3_5_4bit,
                parameters: .init(
                    maxOutputLength: 512,
                   // temperature: 0.7
                )
            )
        case "mistral-7b-q4":
            return LLMLocalSchema(
                model: .mistral7B4bit,
                parameters: .init(
                    maxOutputLength: 512,
                  //  temperature: 0.7
                )
            )
        default:
            // Default to Llama 3.2 1B if model not recognized
            return LLMLocalSchema(
                model: .llama3_2_1B_4bit,
                parameters: .init(
                    maxOutputLength: 512,
                    //temperature: 0.7
                )
            )
        }
    }
}

// MARK: - Error Types
enum LLMError: LocalizedError {
    case modelNotLoaded
    case generationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "Model not loaded. Please load a model before generating."
        case .generationFailed(let reason):
            return "Generation failed: \(reason)"
        }
    }
}
