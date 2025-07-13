//  LocalLLMRunner.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import Foundation
import SpeziLLM
import SpeziLLMLocal

/// Manages local LLM execution using SpeziLLMLocal
class LLMLocalRunner {
    private var currentModel: LLMLocalModel?
    
    /// Load a model and prepare it for inference
    func loadModel(_ model: LLMLocalModel) {
        print("Loading model: \(model.name)")
        currentModel = model
    }
    
    /// Create appropriate schema for the model
    static func createSchema(for model: LLMLocalModel) -> LLMLocalSchema {
        // Map model IDs to actual model configurations
        switch model.id {
        case "llama-3.2-1b":
            return LLMLocalSchema(
                model: .llama3_2_1B_4bit,
                parameters: .init(
                    maxOutputLength: 512
                )
            )
        case "phi-3-mini":
            return LLMLocalSchema(
                model: .phi3_5_mini_4bit,
                parameters: .init(
                    maxOutputLength: 512
                )
            )
        case "mistral-7b-q4":
            return LLMLocalSchema(
                model: .mistral7B_4bit,
                parameters: .init(
                    maxOutputLength: 512
                )
            )
        default:
            // Default to Llama 3.2 1B if model not recognized
            return LLMLocalSchema(
                model: .llama3_2_1B_4bit,
                parameters: .init(
                    maxOutputLength: 512
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
