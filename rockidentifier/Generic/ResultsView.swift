import SwiftUI

struct ResultsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let result: RockIdentificationResult
    let image: UIImage

    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header Image with Rock Name
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 350)
                        .clipped()
                        .overlay(
                            LinearGradient(gradient: Gradient(colors: [.clear, ThemeColors.background.opacity(0.2), ThemeColors.background]), startPoint: .top, endPoint: .bottom)
                        )
                        .overlay(
                            VStack {
                                Spacer()
                                Text(result.rockName)
                                    .font(.system(size: 44, weight: .bold, design: .serif))
                                    .foregroundColor(ThemeColors.primaryText)
                                    .shadow(color: ThemeColors.background.opacity(0.5), radius: 10)
                                    .padding()
                            }
                        )

                    InfoSectionView(title: "Description", content: result.description, icon: icon(for: "Description"))

                    InfoSectionView(title: "Geological Context", content: result.geologicalContext, icon: icon(for: "Geological Context"))

                    InfoSectionView(title: "Fun Fact", content: result.funFact, icon: icon(for: "Fun Fact"))

                    // Properties Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Properties")
                            .font(.system(size: 22, weight: .bold, design: .serif))
                            .foregroundColor(ThemeColors.primaryText)
                            .padding(.horizontal)
                        
                        let rockProperties: [(key: String, value: String)] = [
                            ("Color", result.properties.color),
                            ("Streak", result.properties.streak),
                            ("Hardness", result.properties.hardness),
                            ("Crystal System", result.properties.crystalSystem),
                            ("Market Value", result.marketValue)
                        ].filter { !$0.value.isEmpty }

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible())], spacing: 16) {
                            ForEach(rockProperties, id: \.key) { property in
                                let iconInfo = icon(for: property.key)
                                PropertyCardView(key: property.key, value: property.value, iconName: iconInfo.systemName, iconColor: iconInfo.color)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 40)
            }
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(ThemeColors.primaryText)
                            .padding(12)
                            .background(ThemeColors.surface.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                }
                .padding()
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
    
    private func icon(for key: String) -> (systemName: String, color: Color) {
        switch key {
        // Section Icons
        case "Description":
            return ("text.alignleft", .blue)
        case "Geological Context":
            return ("globe.americas.fill", .green)
        case "Fun Fact":
            return ("sparkles", .orange)
        // Property Icons
        case "Color":
            return ("paintpalette.fill", .purple)
        case "Streak":
            return ("scribble.variable", .brown)
        case "Hardness":
            return ("diamond.fill", .cyan)
        case "Crystal System":
            return ("square.on.square", .indigo)
        case "Market Value":
            return ("dollarsign.circle.fill", .yellow)
        default:
            return ("questionmark.circle", .gray)
        }
    }
}

struct InfoSectionView: View {
    let title: String
    let content: String
    let icon: (systemName: String, color: Color)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon.systemName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(icon.color)
                    .frame(width: 30, height: 30)
                    .background(icon.color.opacity(0.15))
                    .clipShape(Circle())
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundColor(ThemeColors.primaryText)
            }
            
            Text(content)
                .font(.system(size: 17, weight: .regular, design: .default))
                .foregroundColor(ThemeColors.secondaryText)
                .lineSpacing(5)
        }
        .padding()
        .background(ThemeColors.surface)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct PropertyCardView: View {
    let key: String
    let value: String
    let iconName: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: iconName)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor)

            Text(key)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(ThemeColors.secondaryText)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .default))
                .foregroundColor(ThemeColors.primaryText)
                .fixedSize(horizontal: false, vertical: true) // Allow text to wrap

            Spacer(minLength: 0)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(ThemeColors.surface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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