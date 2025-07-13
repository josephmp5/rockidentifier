import Foundation

// This struct needs to match the JSON object returned by the Firebase Function.
struct RockIdentificationResult: Decodable, Hashable, Identifiable {
    var id = UUID()
    let rockName: String
    let confidence: Double
    let description: String
    let properties: RockProperties
    let geologicalContext: String
    let funFact: String
    let marketValue: String

    enum CodingKeys: String, CodingKey {
        case rockName, confidence, description, properties, geologicalContext, funFact, marketValue
    }
}

struct RockProperties: Decodable, Hashable {
    let color: String
    let streak: String
    let hardness: String
    let crystalSystem: String

    enum CodingKeys: String, CodingKey {
        case color = "Color"
        case streak = "Streak"
        case hardness = "Hardness"
        case crystalSystem = "Crystal System"
    }
}
