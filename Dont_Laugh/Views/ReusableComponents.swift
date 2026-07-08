//
//  ReusableComponents.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster and Gemini on 25/01/2026.
//
import SwiftUI

// MARK: - TOP HEADER STRIP
struct TopActionStrip: View {
    let title: String
    
    // Left Item (New!)
    var leftIcon: String? = nil
    var leftAction: (() -> Void)? = nil
    
    // Right Item
    var rightIcon: String? = nil
    var rightAction: (() -> Void)? = nil
    
    // The Color of the text/icons (Always White in new design)
    var contentColor: Color
    
    var body: some View {
        HStack {
            // LEFT BUTTON
            if let icon = leftIcon {
                Button(action: { leftAction?() }) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(contentColor)
                }
            } else {
                Spacer().frame(width: 44) // Balance placeholder
            }
            
            Spacer()
            
            // TITLE
            Text(title)
                .font(.custom(AppTheme.userFontName, size: AppTheme.appFontSize + 2))
                .fontWeight(.bold)
                .foregroundColor(contentColor)
            
            Spacer()
            
            // RIGHT BUTTON
            if let icon = rightIcon {
                Button(action: { rightAction?() }) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(contentColor)
                }
            } else {
                Spacer().frame(width: 44) // Balance placeholder
            }
        }
        .padding()
    }
}

// MARK: - PILL BUTTON
struct PillButton: View {
    let text: String
    let background: Color
    let textColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.custom(AppTheme.userFontName, size: AppTheme.appFontSize))
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Capsule().fill(background))
        }
    }
}

// MARK: - POP UP OVERLAY
struct PopupOverlay: View {
    @ObservedObject var viewModel: GameViewModel
    
    var body: some View {
        if viewModel.showPopup {
            ZStack {
                Color.black.opacity(0.4).ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text(viewModel.popupMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    HStack {
                        if let leftTitle = viewModel.popupLeftAction {
                            Button(leftTitle.uppercased()) {
                                viewModel.closePopup()
                            }
                            .foregroundColor(.blue)
                            Spacer()
                        }
                        
                        if let rightTitle = viewModel.popupRightAction {
                            Button(rightTitle) {
                                if viewModel.popupType == .removeConfirm {
                                    viewModel.confirmRemoveCard()
                                } else {
                                    viewModel.closePopup()
                                }
                            }
                            .bold()
                            .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .frame(width: 300)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 10)
            }
            .transition(.opacity)
        }
    }
}
