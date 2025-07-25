//
//  RemindersManager.swift
//  GroceryGen
//
//  Created by ZhuMacPro on 7/22/25.
//

import Foundation
import EventKit

class RemindersManager: ObservableObject {
    private let eventStore = EKEventStore()
    
    // Request access based on iOS version
    func requestAccess(completion: @escaping (Bool) -> Void) {
        if #available(iOS 17, *) {
            eventStore.requestFullAccessToReminders { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        } else {
            eventStore.requestAccess(to: .reminder) { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    }
    
    // Create a new list and add items
    func createShoppingList(title: String, items: [String]) {
        requestAccess { granted in
            guard granted else {
                print("Reminders access not granted.")
                return
            }
            
            // Get the appropriate source (e.g., iCloud)
            guard let source = self.eventStore.defaultCalendarForNewReminders()?.source else {
                print("Could not determine default reminder source.")
                return
            }
            
            // Create new list (calendar)
            let shoppingList = EKCalendar(for: .reminder, eventStore: self.eventStore)
            shoppingList.title = title
            shoppingList.source = source
            
            do {
                try self.eventStore.saveCalendar(shoppingList, commit: true)
            } catch {
                print("Failed to create new reminders list: \(error.localizedDescription)")
                return
            }
            
            // Add items to the list
            for item in items {
                let reminder = EKReminder(eventStore: self.eventStore)
                reminder.title = item
                reminder.calendar = shoppingList
                
                do {
                    try self.eventStore.save(reminder, commit: true)
                } catch {
                    print("Failed to save reminder '\(item)': \(error.localizedDescription)")
                }
            }
            
            print("✅ Shopping list '\(title)' created with \(items.count) items.")
        }
    }
}
