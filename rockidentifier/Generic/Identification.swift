import SwiftUI

struct Identification: Codable, Identifiable, Hashable {
    let id: UUID
    let imageData: Data
    let itemName: String
    let identificationDate: Date

    var image: Image {
        Image(uiImage: UIImage(data: imageData) ?? UIImage())
    }
}
