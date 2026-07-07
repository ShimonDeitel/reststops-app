import Foundation

struct RestStop: Identifiable, Codable, Equatable {
    let id: UUID
    var stopName: String
    var highway: String
    var rating: Int
    var hasFood: Bool
    var hasFuel: Bool
    var hasRestrooms: Bool
    var notes: String

    init(id: UUID = UUID(), stopName: String, highway: String, rating: Int, hasFood: Bool, hasFuel: Bool, hasRestrooms: Bool, notes: String) {
        self.id = id
        self.stopName = stopName
        self.highway = highway
        self.rating = rating
        self.hasFood = hasFood
        self.hasFuel = hasFuel
        self.hasRestrooms = hasRestrooms
        self.notes = notes
    }
}
