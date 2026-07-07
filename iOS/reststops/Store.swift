import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [RestStop] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier item cap. Deliberately kept above the seed data count
    /// so a fresh install never opens directly into the paywall.
    static let freeLimit = 8

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("reststops_items.json")
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || items.count < Store.freeLimit
    }

    func add(_ item: RestStop) {
        guard canAddMore else { return }
        items.append(item)
        save()
    }

    func update(_ item: RestStop) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: RestStop) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([RestStop].self, from: data) {
            items = decoded
        } else {
            items = [
        RestStop(stopName: "Sample Stopname 1", highway: "Sample Highway 1", rating: 3, hasFood: true, hasFuel: true, hasRestrooms: true, notes: "Sample Notes 1"),
        RestStop(stopName: "Sample Stopname 2", highway: "Sample Highway 2", rating: 4, hasFood: false, hasFuel: false, hasRestrooms: false, notes: "Sample Notes 2"),
        RestStop(stopName: "Sample Stopname 3", highway: "Sample Highway 3", rating: 5, hasFood: true, hasFuel: true, hasRestrooms: true, notes: "Sample Notes 3")
            ]
            save()
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }
}
