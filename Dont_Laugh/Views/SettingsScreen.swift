//
//  SettingsScreen.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster and Gemini on 25/01/2026.
//
import SwiftUI
import UniformTypeIdentifiers

struct SettingsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameViewModel
    
    // Sheet States
    @State private var showInput = false
    @State private var showFileManager = false
    @State private var showInstructions = false // For the menu item
    @State private var showFileImporter = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.systemCanvas.ignoresSafeArea()
                
                List {
                    // Toggles
                    Toggle("Display mature content", isOn: $viewModel.showAdultContent)
                        .listRowBackground(Color.clear)
                    
                    // Actions
                    Button("Add a card") { showInput = true }
                        .listRowBackground(Color.clear)
                    
                    Button("Restore a card") { /* Future Feature */ }
                        .listRowBackground(Color.clear)
                    
                    Button("Add a card pack (Upload CSV)") { showFileImporter = true }
                        .listRowBackground(Color.clear)
                    
                    Button("Manage Card Packs") { showFileManager = true }
                        .listRowBackground(Color.clear)
                    
                    // Note: "How to Play" is now  on Main Screen.
                    // Button("How to Play") { showInstructions = true }
                    //    .listRowBackground(Color.clear)
                    // Note 2: see MODAL HANDLING below
                    
                    // NEW: Simplified Color Palette Selector
                    VStack(alignment: .leading) {
                        Text("Colours")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(AppTheme.palettes, id: \.id) { palette in
                                    Button(action: {
                                        viewModel.currentPaletteIndex = palette.id
                                    }) {
                                        // Simple Color Block (No Text)
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(palette.color)
                                            .frame(width: 60, height: 60)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(Color.gray, lineWidth: viewModel.currentPaletteIndex == palette.id ? 4 : 1)
                                            )
                                            .shadow(radius: 2)
                                    }
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(.vertical, 5)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark").foregroundColor(.black)
                        }
                    }
                }
            }
            // MODAL HANDLING
            .background(EmptyView().sheet(isPresented: $showInput) { InputScreen(viewModel: viewModel) })
            .background(EmptyView().sheet(isPresented: $showFileManager) { FileManagerScreen() })
            //.background(EmptyView().sheet(isPresented: $showInstructions) { InstructionsScreen() })
            .background(EmptyView().fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.commaSeparatedText]) { result in
                    if let url = try? result.get() { viewModel.uploadCardPack(fileURL: url) }
                }
            )
        }
    }
}

