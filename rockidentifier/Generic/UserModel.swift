import Foundation
import FirebaseFirestore

struct UserModel: Codable, Identifiable {
    // By using the @DocumentID property wrapper, Firestore will automatically
    // populate this field with the document's ID.
    @DocumentID var id: String? = UUID().uuidString
    let uid: String
    let isPremium: Bool?
    let subscriptionActive: Bool?
    let tokens: Int?

    // All users need tokens to access identification features
    var hasAccess: Bool {
        return (tokens ?? 0) > 0
    }

    enum CodingKeys: String, CodingKey {
        case uid
        case isPremium
        case subscriptionActive
        case tokens
    }
}
