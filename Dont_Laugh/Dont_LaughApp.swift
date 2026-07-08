//
//  Dont_LaughApp.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster and Gemini on 25/01/2026.
//
import SwiftUI
import SwiftData

@main
struct Dont_LaughApp: App {
    var body: some Scene {
        WindowGroup {
            MainScreen()
        }
        .modelContainer(for: Card.self) // Initializes the database
    }
}
