import SwiftUI

struct ImagePreview: View {
    var image: UIImage
    var onClear: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)

            Button(action: onClear) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
            .padding(8)
        }
        .padding()
    }
}
