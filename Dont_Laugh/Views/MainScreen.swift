//
//  MainScreen.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster and Gemini on 25/01/2026.
//
import SwiftUI
import SwiftData

struct MainScreen: View {
    @Environment(\.modelContext) var context
    @StateObject private var viewModel = GameViewModel()
    @State private var showSettings = false
    @State private var showInstructions = false // New State for Question Mark
    
    var body: some View {
        ZStack {
            // Background: Dynamic User Color (Red/Blue/Yellow/Black)
            viewModel.currentTheme.color.ignoresSafeArea()
            
            VStack {
                // Header: White Text/Icons
                TopActionStrip(
                    title: "Don't Laugh",
                    leftIcon: "questionmark.circle.fill", // New Question Mark
                    leftAction: { showInstructions = true },
                    rightIcon: "gearshape.fill",
                    rightAction: { showSettings = true },
                    contentColor: AppTheme.uiTextColor // Always White
                )
                
                Spacer()
                
                // READING PANE (The White Card)
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppTheme.cardBackground) // Always White
                        .shadow(radius: 5)
                    
                    ScrollView {
                        if let card = viewModel.currentCard {
                            Text(card.text)
                                .font(.custom(AppTheme.userFontName, size: AppTheme.appFontSize))
                                .foregroundColor(AppTheme.cardTextColor) // Always Black
                                .multilineTextAlignment(.center)
                                .padding()
                        } else {
                            Text("No cards available.\nCheck your settings or add a pack!")
                                .font(.custom(AppTheme.userFontName, size: AppTheme.appFontSize))
                                .foregroundColor(AppTheme.cardTextColor)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    .padding()
                }
                .padding(.horizontal, 20)
                .frame(maxHeight: 500) // Keeps the card from stretching too far
                
                Spacer()
                
                // Bottom Strip
                HStack {
                    // Remove Button: White Text (to contrast with colored background)
                    Button("Remove") {
                        viewModel.requestRemoveCard()
                    }
                    .font(.system(size: AppTheme.appFontSize))
                    .foregroundColor(AppTheme.uiTextColor) // White
                    
                    Spacer()
                    
                    // NEXT Button: White Background, Colored Text
                    PillButton(
                        text: "NEXT",
                        background: Color.white,
                        textColor: viewModel.currentTheme.color, // Matches Canvas
                        action: { viewModel.pickNextCard() }
                    )
                }
                .padding()
            }
            
            // Pop Up Layer
            PopupOverlay(viewModel: viewModel)
        }
        .onAppear {
            viewModel.setContext(context)
        }
        // Sheets
        .sheet(isPresented: $showSettings) {
            SettingsScreen(viewModel: viewModel)
        }
        .sheet(isPresented: $showInstructions) {
            InstructionsScreen() // Opens via Question Mark
        }
    }
}
