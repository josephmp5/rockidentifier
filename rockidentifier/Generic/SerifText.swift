import SwiftUI

struct SerifText: View {
    var text: String
    var size: CGFloat
    var color: Color

    init(_ text: String, size: CGFloat, color: Color = .primary) {
        self.text = text
        self.size = size
        self.color = color
    }

    var body: some View {
        Text(text)
            .font(.custom("Georgia", size: size))
            .foregroundColor(color)
    }
}
