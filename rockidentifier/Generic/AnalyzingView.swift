import SwiftUI

struct AnalyzingView: View {
    @State private var isAnimating = false
    @State private var rotationAngle: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var textOpacity: Double = 1.0
    
    private let messages = [
        "🔍 Analyzing crystal structure...",
        "💎 Identifying mineral composition...",
        "🧪 Processing geological data...",
        "⚡ Finalizing results..."
    ]
    @State private var currentMessageIndex = 0

    var body: some View {
        ZStack {
            // Full screen background
            ThemeColors.background
                .ignoresSafeArea(.all)
            
            // Content centered on screen
            VStack(spacing: 30) {
                // Animated crystal icon
                ZStack {
                    // Outer ring
                    Circle()
                        .stroke(ThemeColors.primaryAction.opacity(0.3), lineWidth: 2)
                        .frame(width: 100, height: 100)
                        .scaleEffect(pulseScale)
                    
                    // Inner rotating ring
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(
                            LinearGradient(
                                colors: [ThemeColors.primaryAction, ThemeColors.accent],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(rotationAngle))
                    
                    // Center crystal icon
                    Image(systemName: "diamond.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(ThemeColors.primaryAction)
                        .scaleEffect(isAnimating ? 1.1 : 0.9)
                }
                
                // Dynamic message with typing effect
                VStack(spacing: 12) {
                    Text(messages[currentMessageIndex])
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(ThemeColors.primaryText)
                        .opacity(textOpacity)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    // Progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<4) { index in
                            Circle()
                                .frame(width: 6, height: 6)
                                .foregroundColor(
                                    index <= currentMessageIndex ? 
                                    ThemeColors.primaryAction : 
                                    ThemeColors.secondaryText.opacity(0.3)
                                )
                                .scaleEffect(index == currentMessageIndex ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 0.3), value: currentMessageIndex)
                        }
                    }
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(ThemeColors.surface)
                    .shadow(color: ThemeColors.primaryAction.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Rotation animation
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.2
        }
        
        // Scale animation
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
        
        // Message cycling
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 0.3)) {
                textOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                currentMessageIndex = (currentMessageIndex + 1) % messages.count
                withAnimation(.easeInOut(duration: 0.3)) {
                    textOpacity = 1
                }
            }
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
