// Force re-compile
import SwiftUI

struct HistoryView: View {
    @StateObject private var historyManager = HistoryManager.shared
    @State private var showingClearAlert = false

    fileprivate let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            ThemeColors.background
                .ignoresSafeArea(.all)

            if historyManager.history.isEmpty {
                emptyStateView
            } else {
                historyGridView
            }
        }
        .alert(isPresented: $showingClearAlert) {
            Alert(
                title: Text("Clear History"),
                message: Text("Are you sure you want to delete all identification history? This action cannot be undone."),
                primaryButton: .destructive(Text("Clear")) {
                    historyManager.clearHistory()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

private extension HistoryView {
    var historyGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(historyManager.history) { item in
                    NavigationLink(destination: ResultsView(result: RockIdentificationResult(
                        rockName: item.rockName,
                        confidence: 0.95,
                        description: "Historical identification",
                        properties: RockProperties(
                            color: "Unknown",
                            streak: "Unknown",
                            hardness: "Unknown",
                            crystalSystem: "Unknown"
                        ),
                        geologicalContext: "Previously identified crystal",
                        funFact: "This crystal was identified from your collection.",
                        marketValue: "Value varies based on quality and size"
                    ), image: UIImage(data: item.imageData) ?? UIImage())) {
                        HistoryCardView(item: item)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(ThemeColors.accent.opacity(0.15))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "rectangle.stack.fill.badge.plus")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundColor(ThemeColors.accent)
            }
            
            VStack(spacing: 12) {
                Text("No History Yet")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ThemeColors.primaryText)
                
                Text("Your identified crystals will appear here.")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(ThemeColors.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
    }
}

struct HistoryCardView: View {
    let item: HistoryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section with better aspect ratio
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipped()
                    .cornerRadius(12, corners: [.topLeft, .topRight])
            } else {
                ZStack {
                    ThemeColors.surface
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(ThemeColors.accent.opacity(0.6))
                }
                .frame(height: 140)
                .cornerRadius(12, corners: [.topLeft, .topRight])
            }

            // Text content with better spacing
            VStack(alignment: .leading, spacing: 6) {
                Text(item.rockName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeColors.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text(item.date, style: .date)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(ThemeColors.secondaryText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(ThemeColors.surface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ThemeColors.accent.opacity(0.1), lineWidth: 1)
        )
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoryView()
        }
        .preferredColorScheme(.dark)
    }
}
