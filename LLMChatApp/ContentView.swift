//
//  ContentView.swift
//  LLMChatApp
//
//  Created by Mehul Bhujwala on 13/7/2025.
//
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ModelDownloadView()
                .tabItem {
                    Label("Models", systemImage: "square.and.arrow.down")
                }
                .tag(0)
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
                .tag(1)
        }
    }
}
