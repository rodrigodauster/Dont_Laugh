//
//  InputScreen.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster and Gemini on 25/01/2026.
//
import SwiftUI

struct InputScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: GameViewModel
    
    @State private var textInput: String = ""
    @State private var isAdult: Bool = false
    
    var body: some View {
        ZStack {
            AppTheme.systemCanvas.ignoresSafeArea()
            
            VStack {
                // HEADER (Fixed to match new definition)
                TopActionStrip(
                    title: "Add a Card",
                    rightIcon: "xmark",
                    rightAction: { presentationMode.wrappedValue.dismiss() },
                    contentColor: .black
                )
                
                // FORM
                VStack(spacing: 20) {
                    TextField("Enter card text here...", text: $textInput, axis: .vertical)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .frame(minHeight: 100)
                    
                    Toggle("Mature Content (18+)", isOn: $isAdult)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                    
                    Button(action: {
                        if !textInput.isEmpty {
                            viewModel.saveNewCard(text: textInput, isAdult: isAdult)
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("SAVE CARD")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding()
                
                Spacer()
            }
        }
    }
}
