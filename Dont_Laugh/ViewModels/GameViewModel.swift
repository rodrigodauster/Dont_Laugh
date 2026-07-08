//
//  GameViewModel.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster and Gemini on 25/01/2026.
//
import Foundation
import SwiftData
import SwiftUI
import Combine

// MARK: - VIEW MODEL

@MainActor
class GameViewModel: ObservableObject {
    // DEPENDENCY: SwiftData Context
    var modelContext: ModelContext?
    
    // PUBLISHED STATE
    @Published var currentCard: Card?
    @Published var showAdultContent: Bool = false {
        didSet { pickNextCard() }
    }
    
    // --- NEW: COLOR PALETTE STATE ---
    @Published var currentPaletteIndex: Int = 0 {
        didSet { savePaletteChoice() }
    }
    
    var currentTheme: AppTheme.Palette {
        if currentPaletteIndex < AppTheme.palettes.count {
            return AppTheme.palettes[currentPaletteIndex]
        }
        return AppTheme.palettes[0] // Fallback
    }
    // --------------------------------
    
    // POP-UP STATE
    @Published var showPopup: Bool = false
    @Published var popupMessage: String = ""
    @Published var popupLeftAction: String? = nil
    @Published var popupRightAction: String? = nil
    @Published var popupType: PopupType = .none
    
    enum PopupType {
        case none, removeConfirm, saved, error, loaded
    }
    
    // INITIALIZER
    init() {
        loadPaletteChoice() // Load saved color
    }
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
        // Check if empty, load starter data
        loadStarterPackIfNeeded()
        pickNextCard()
    }

    // MARK: - 1. MAIN SCREEN LOGIC
    
    func pickNextCard() {
        guard let context = modelContext else { return }
        
        // Fetch all cards where displayFlag == TRUE
        let descriptor = FetchDescriptor<Card>(predicate: #Predicate { card in
            card.displayFlag == true
        })
        
        do {
            let allCards = try context.fetch(descriptor)
            
            // Filter by Adult Content Logic
            let validCards = allCards.filter { card in
                // Logic A: IF AdultContent flag == FALSE -> Keep it
                if card.isAdult == false { return true }
                
                // Logic B: IF AdultContent flag == TRUE and Toggle == TRUE -> Keep it
                if card.isAdult == true && showAdultContent == true { return true }
                
                // ELSE Discard
                return false
            }
            
            // Random Select
            currentCard = validCards.randomElement()
            
        } catch {
            print("Fetch failed")
        }
    }
    
    func requestRemoveCard() {
        guard currentCard != nil else { return }
        // Show Pop-up
        popupType = .removeConfirm
        popupMessage = "Are you sure you want to remove this card?"
        popupLeftAction = "UNDO"
        popupRightAction = "Remove"
        showPopup = true
    }
    
    func confirmRemoveCard() {
        guard let card = currentCard else { return }
        card.displayFlag = false
        pickNextCard()
        closePopup()
    }
    
    // MARK: - 3. INPUT SCREEN LOGIC
    
    func saveNewCard(text: String, isAdult: Bool) {
        guard let context = modelContext else { return }
        
        let newCard = Card(
            id: UUID(),
            text: text,
            cardPack: "Personal",
            isAdult: isAdult,
            packDeletable: true
        )
        
        context.insert(newCard)
        triggerTemporaryPopup(message: "New card created")
    }
    
    // MARK: - 4. UPLOAD LOGIC (CSV)
    
    func uploadCardPack(fileURL: URL) {
        guard let context = modelContext else { return }
        
        // 1. Validation: File Type
        guard fileURL.pathExtension.lowercased() == "csv" else {
            showError("Upload error: filtype must be CSV")
            return
        }
        
        // 2. Read File
        guard let data = try? String(contentsOf: fileURL) else {
            showError("Upload error: Could not read file.")
            return
        }
        
        var rows = data.components(separatedBy: .newlines)
        rows.removeAll { $0.isEmpty }
        
        // Parse First Row
        guard let firstRow = rows.first else { return }
        let columns = firstRow.components(separatedBy: ",")
        let packName = columns[0].trimmingCharacters(in: .whitespaces)
        
        // 3. Validation: Long Pack Name
        if packName.count > AppConstants.nameLimit {
            showError("Upload error: Card pack name too long.")
            return
        }
        
        // 4. Validation: Duplicate Pack
        let dupeCheck = FetchDescriptor<Card>(predicate: #Predicate { $0.cardPack == packName })
        if let count = try? context.fetchCount(dupeCheck), count > 0 {
            showError("Upload error: Card pack already exists.")
            return
        }
        
        // 5. Validation: Memory Limit
        let currentMemory = estimateDatabaseSize()
        let newFileSize = Double(data.count) / (1024 * 1024) // in MB
        if (currentMemory + newFileSize) > Double(AppConstants.memoryLimitMB) {
            showError("Upload error: Out of memory.")
            return
        }
        
        // 6. Loop and Insert Rows
        for row in rows {
            let cols = row.components(separatedBy: ",")
            if cols.count >= 3 {
                let pName = cols[0]
                let body = cols[1]
                let adultFlagStr = cols[2].trimmingCharacters(in: .whitespaces).lowercased()
                
                // Validation: Long Card
                if body.count > AppConstants.characterLimit {
                    showError("Upload error: Card text longer than 1200 characters.")
                    return
                }
                
                var adultBool = false
                if adultFlagStr == "true" { adultBool = true }
                else if adultFlagStr == "false" { adultBool = false }
                else {
                    showError("Upload error: AdultContent flag must be True or False.")
                    return
                }
                
                let newCard = Card(
                    text: body,
                    cardPack: pName,
                    isAdult: adultBool,
                    packDeletable: true
                )
                context.insert(newCard)
            }
        }
        
        triggerTemporaryPopup(message: "New pack uploaded")
        pickNextCard()
    }
    
    // MARK: - HELPER FUNCTIONS
    
    private func loadStarterPackIfNeeded() {
        guard let context = modelContext else { return }
        
        if let count = try? context.fetchCount(FetchDescriptor<Card>()), count == 0 {
            let starterCardsData = [
                ("Why don't scientists trust atoms?\n\nBecause they make up everything!", false),
                ("I told my wife she was drawing her eyebrows too high.\n\nShe looked surprised.", false),
                ("You got to hand it to blind prostitutes.", true)
            ]
            
            for (text, adult) in starterCardsData {
                let card = Card(
                    text: text,
                    cardPack: "Starter Pack",
                    isAdult: adult,
                    packDeletable: false
                )
                context.insert(card)
            }
        }
    }
    
    private func estimateDatabaseSize() -> Double {
        return 0.5 // Placeholder
    }
    
    // --- PALETTE PERSISTENCE ---
    private func savePaletteChoice() {
        UserDefaults.standard.set(currentPaletteIndex, forKey: "user_palette_index")
    }
    
    private func loadPaletteChoice() {
        let savedIndex = UserDefaults.standard.integer(forKey: "user_palette_index")
        if savedIndex >= 0 && savedIndex < AppTheme.palettes.count {
            self.currentPaletteIndex = savedIndex
        }
    }
    // ---------------------------
    
    // MARK: - POPUP HANDLING
    
    func showError(_ message: String) {
        popupType = .error
        popupMessage = message
        popupRightAction = "Close"
        showPopup = true
    }
    
    func triggerTemporaryPopup(message: String) {
        popupType = .saved
        popupMessage = message
        popupLeftAction = nil
        popupRightAction = nil
        showPopup = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.popupDuration) {
            self.closePopup()
        }
    }
    
    func closePopup() {
        showPopup = false
    }
}
