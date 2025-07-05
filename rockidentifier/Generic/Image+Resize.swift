import UIKit

extension UIImage {
    func resized(to size: CGSize, compressionQuality: CGFloat = 0.8) -> Data? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let resizedImage = renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return resizedImage.jpegData(compressionQuality: compressionQuality)
    }
}
