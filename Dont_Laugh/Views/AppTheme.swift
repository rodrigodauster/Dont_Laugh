//
//  AppTheme.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster and Gemini on 25/01/2026.
//
import SwiftUI

struct AppTheme {
    // FONTS
    static let userFontName = "Chalkboard SE"
    static let appFontName = "System"
    static let appFontSize: CGFloat = 24.0
    
    // STATIC RULES (New Design)
    static let cardBackground = Color.white
    static let cardTextColor = Color.black
    static let uiTextColor = Color.white
    
    // SYSTEM PALETTE (Menus)
    static let systemCanvas = Color(white: 0.9)
    static let systemFontColor = Color.black
    
    // MARK: - DYNAMIC USER PALETTES
    struct Palette {
        let id: Int
        let color: Color // The main background color
    }
    
    static let palettes: [Palette] = [
        Palette(id: 0, color: .red),
        Palette(id: 1, color: .blue),
        Palette(id: 2, color: .yellow),
        Palette(id: 3, color: .black)
    ]
}
