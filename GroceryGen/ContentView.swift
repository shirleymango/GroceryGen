//
//  ContentView.swift
//  GroceryGen
//
//  Created by ZhuMacPro on 7/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var remindersManager = RemindersManager()
    
    // Sample ingredient list
    @State private var ingredients = [
        "Milk", "Eggs", "Flour", "Sugar", "Butter", "Apples", "Bananas"
    ]
    
    // Selection state
    @State private var selectedIngredients: Set<String> = []
    
    var body: some View {
        NavigationView {
            VStack {
                // Ingredient selection list
                List(ingredients, id: \.self, selection: $selectedIngredients) { ingredient in
                    Text(ingredient)
                }
                .environment(\.editMode, .constant(.active)) // enable multi-selection
                .navigationTitle("Select Ingredients")
                
                // Create Shopping List button
                Button(action: {
                    if selectedIngredients.isEmpty {
                        print("⚠️ No ingredients selected.")
                    } else {
                        remindersManager.createShoppingList(
                            title: "GroceryGen List",
                            items: Array(selectedIngredients)
                        )
                        selectedIngredients.removeAll() // Optional: clear selection after
                    }
                }) {
                    Text("Create Shopping List")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding([.horizontal, .bottom])
                }
                
                Button("Open Reminders App") {
                    if let url = URL(string: "x-apple-reminderkit://") {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
    }
}
