//
//  CardModels.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster with Gemini on 25/01/2026.
//
import Foundation
import SwiftData

// MARK: - DATA MODELS

/// Represents a single flashcard with a joke.
@Model
class Card: Identifiable {
    @Attribute(.unique) var id: UUID
    var text: String
    var cardPack: String
    var isAdult: Bool
    
    // State Flags
    var displayFlag: Bool = true
    var packDeletable: Bool
    
    init(id: UUID = UUID(), text: String, cardPack: String, isAdult: Bool, packDeletable: Bool) {
        self.id = id
        self.text = text
        self.cardPack = cardPack
        self.isAdult = isAdult
        self.packDeletable = packDeletable
        self.displayFlag = true
    }
}

// MARK: - GLOBAL CONSTANTS
struct AppConstants {
    static let characterLimit = 1200
    static let nameLimit = 20
    static let memoryLimitMB = 30
    static let popupDuration: CGFloat = 2.0
    
    static let instructionsBody = """
    For 2 or more players.
    
    Take turns reading the jokes to each other. Whoever laughs, or even smiles(!), loses.
    
    After your turn, pass the phone to the next player. After they click on "Next", it's their turn to try to make the others laugh.
    
    Try not to laugh ;-)
    """
}
