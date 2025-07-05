import SwiftUI

struct AnalyzingView: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.themeAccent)
                .rotationEffect(.degrees(isAnimating ? 15 : -15))
                .animation(
                    Animation.easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            Text("Analyzing Rock")
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundColor(ThemeColors.primaryText)
            
            HStack(spacing: 5) {
                ForEach(0..<3) { index in
                    Circle()
                        .frame(width: 8, height: 8)
                        .foregroundColor(ThemeColors.primaryAction.opacity(0.5))
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .animation(Animation.easeInOut(duration: 0.6).repeatForever().delay(0.2 * Double(index)), value: isAnimating)
                }
            }
        }
        .padding(40)
        .background(ThemeColors.surface)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .onAppear {
            isAnimating = true
        }
    }
}

struct AnalyzingView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            AnalyzingView()
        }
    }
}
