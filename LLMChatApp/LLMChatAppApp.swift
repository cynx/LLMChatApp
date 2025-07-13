//
//  LLMChatAppApp.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//

import SwiftUI
import Spezi
import SpeziLLM
import SpeziLLMLocal
import SpeziLLMLocalDownload

@main
struct LLMChatApp: App {
    @UIApplicationDelegateAdaptor(LLMChatAppDelegate.self) var appDelegate
    @StateObject private var modelManager = ModelManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelManager)
                .spezi(appDelegate)
        }
    }
}

// MARK: - Spezi App Delegate
class LLMChatAppDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            LLMRunner {
                // Configure the LLM Local Platform for on-device execution
                LLMLocalPlatform()
            }
        }
    }
}
