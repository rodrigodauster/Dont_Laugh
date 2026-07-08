//
//  FileManagerScreen.swift
//  Dont_Laugh
//
//  Created by Rodrigo Dauster and Gemini on 25/01/2026.
//
import SwiftUI
import SwiftData

struct FileManagerScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) var context
    
    // Fetch all unique pack names
    @Query var cards: [Card]
    
    var uniquePacks: [String] {
        let packs = cards.map { $0.cardPack }
        return Array(Set(packs)).sorted()
    }
    
    var body: some View {
        ZStack {
            AppTheme.systemCanvas.ignoresSafeArea()
            
            VStack {
                // HEADER (Fixed to match new definition)
                TopActionStrip(
                    title: "Manage Packs",
                    rightIcon: "xmark",
                    rightAction: { presentationMode.wrappedValue.dismiss() },
                    contentColor: .black
                )
                
                List {
                    ForEach(uniquePacks, id: \.self) { pack in
                        HStack {
                            Text(pack)
                            Spacer()
                            if let count = try? cards.filter({ $0.cardPack == pack }).count {
                                Text("\(count) cards").foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deletePack)
                }
                .listStyle(.plain)
            }
        }
    }
    
    func deletePack(at offsets: IndexSet) {
        for index in offsets {
            let packName = uniquePacks[index]
            // Find all cards in this pack
            let cardsToDelete = cards.filter { $0.cardPack == packName }
            
            // Delete them
            for card in cardsToDelete {
                context.delete(card)
            }
        }
    }
}
