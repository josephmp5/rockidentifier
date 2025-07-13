import SwiftUI

struct ResultsView: View {
    let result: RockIdentificationResult
    let image: UIImage

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [ThemeColors.background, ThemeColors.surface],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero Image Section
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 320)
                            .cornerRadius(20)
                            .clipped()
                        
                        // Overlay gradient
                        LinearGradient(
                            colors: [Color.clear, Color.black.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .cornerRadius(20)
                        
                        // Confidence badge
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                VStack(spacing: 4) {
                                    Text("🎯")
                                        .font(.title2)
                                    Text(String(format: "%.0f%%", result.confidence * 100))
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Match")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(12)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .padding(16)
                            }
                        }
                    }
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                    
                    // Rock Name & Description
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("🧿")
                                .font(.title)
                            Text(result.rockName)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(ThemeColors.primaryText)
                        }
                        
                        Text(result.description)
                            .font(.body)
                            .foregroundColor(ThemeColors.secondaryText)
                            .lineSpacing(2)
                    }
                    .padding(20)
                    .background(ThemeColors.surface, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

                    // Properties Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("🔍")
                                .font(.title2)
                            Text("Rock Properties")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(ThemeColors.primaryText)
                        }
                        
                        VStack(spacing: 12) {
                            PropertyRow(icon: "🎨", title: "Color", value: result.properties.color, color: .orange)
                            PropertyRow(icon: "✏️", title: "Streak", value: result.properties.streak, color: .brown)
                            PropertyRow(icon: "🔨", title: "Hardness", value: result.properties.hardness, color: .cyan)
                            PropertyRow(icon: "🔶", title: "Crystal System", value: result.properties.crystalSystem, color: .purple)
                        }
                    }
                    .padding(20)
                    .background(ThemeColors.surface, in: RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)

                    // Detailed Information Sections
                    VStack(spacing: 16) {
                        DetailSection(
                            icon: "🌍", 
                            title: "Geological Context", 
                            content: result.geologicalContext,
                            color: .green
                        )
                        
                        DetailSection(
                            icon: "🤔", 
                            title: "Fun Fact", 
                            content: result.funFact,
                            color: .blue
                        )
                        
                        DetailSection(
                            icon: "💰", 
                            title: "Market Value", 
                            content: result.marketValue,
                            color: .yellow
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Beautiful Components

private struct PropertyRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 16) {
            // Icon container
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text(icon)
                    .font(.title3)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ThemeColors.secondaryText)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.primaryText)
            }
            
            Spacer()
            
            // Decorative element
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(color)
        }
        .padding(16)
        .background(color.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct DetailSection: View {
    let icon: String
    let title: String
    let content: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Text(icon)
                        .font(.title2)
                }
                
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(ThemeColors.primaryText)
                
                Spacer()
            }
            
            // Content
            Text(content)
                .font(.body)
                .foregroundColor(ThemeColors.secondaryText)
                .lineSpacing(3)
                .padding(.leading, 8)
        }
        .padding(20)
        .background(ThemeColors.surface, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}


struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        let previewResult = RockIdentificationResult(
            rockName: "Quartz",
            confidence: 0.95,
            description: "Quartz is a hard, crystalline mineral composed of silica. It is the second most abundant mineral in Earth's continental crust, behind feldspar.",
            properties: RockProperties(
                color: "Colorless, White, Purple, Pink, Brown, Black",
                streak: "White",
                hardness: "7",
                crystalSystem: "Trigonal"
            ),
            geologicalContext: "Found in all forms of rock: igneous, metamorphic and sedimentary. It is a common constituent of granite and other felsic igneous rocks.",
            funFact: "Some forms of quartz, such as amethyst and citrine, are considered semi-precious gemstones.",
            marketValue: "$10 - $100 per specimen"
        )
        ResultsView(result: previewResult, image: UIImage(named: "placeholder-image")!)
    }
}