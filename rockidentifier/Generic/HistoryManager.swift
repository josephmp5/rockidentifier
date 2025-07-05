import Foundation
import SwiftUI

// Represents a single identification record in the history.
struct HistoryItem: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let rockName: String
    let imageData: Data

    static func == (lhs: HistoryItem, rhs: HistoryItem) -> Bool {
        lhs.id == rhs.id
    }
}

// Manages the collection of identification history items.
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    private let historyKey = "rockIdentificationHistory"

    @Published var history: [HistoryItem] = []

    private init() {
        loadHistory()
    }

    func add(imageData: Data, rockName: String) {
        let newItem = HistoryItem(id: UUID(), date: Date(), rockName: rockName, imageData: imageData)
        history.insert(newItem, at: 0)
        saveHistory()
    }

    func delete(at offsets: IndexSet) {
        history.remove(atOffsets: offsets)
        saveHistory()
    }

    func clearHistory() {
        history.removeAll()
        saveHistory()
    }

    private func saveHistory() {
        do {
            let encodedData = try JSONEncoder().encode(history)
            UserDefaults.standard.set(encodedData, forKey: historyKey)
        } catch {
            print("HistoryManager: Failed to save history: \(error.localizedDescription)")
        }
    }

    private func loadHistory() {
        guard let savedData = UserDefaults.standard.data(forKey: historyKey) else { return }
        do {
            history = try JSONDecoder().decode([HistoryItem].self, from: savedData)
        } catch {
            print("HistoryManager: Failed to load history: \(error.localizedDescription)")
        }
    }
}