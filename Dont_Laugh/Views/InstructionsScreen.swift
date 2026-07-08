//
//  InstructionsScreen.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster and Gemini on 25/01/2026.
//
import SwiftUI

struct InstructionsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            AppTheme.systemCanvas.ignoresSafeArea()
            
            VStack {
                TopActionStrip(
                    title: "How to Play",
                    rightIcon: "xmark",
                    rightAction: { presentationMode.wrappedValue.dismiss() },
                    contentColor: .black // Keep black for this system screen
                )
                
                // White Card for Instructions
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(radius: 2)
                    
                    ScrollView {
                        Text(AppConstants.instructionsBody)
                            .font(.custom(AppTheme.userFontName, size: AppTheme.appFontSize))
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                .padding()
            }
        }
    }
}
