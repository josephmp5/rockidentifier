import SwiftUI

struct HistoryView: View {
    @Binding var showPaywall: Bool

    init(showPaywall: Binding<Bool>) {
        self._showPaywall = showPaywall
    }

    @StateObject private var historyManager = HistoryManager.shared
    @State private var showingClearAlert = false

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            
            VStack {
                if historyManager.history.isEmpty {
                    emptyStateView
                } else {
                    historyGridView
                }
            }
            .navigationTitle("My Collection")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showPaywall = true }) {
                        Image(systemName: "crown.fill")
                            .foregroundColor(ThemeColors.primaryAction)
                    }

                    if !historyManager.history.isEmpty {
                        Button {
                            showingClearAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(ThemeColors.accent)
                        }
                    }
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
    
    private var historyGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(historyManager.history) {
                    HistoryCardView(item: $0)
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack {
            Spacer()
            Image(systemName: "rectangle.stack.fill.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(ThemeColors.accent)
            Text("No History Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.primaryText)
                .padding(.top)
            Text("Your identified rocks will appear here.")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(ThemeColors.secondaryText)
            Spacer()
            Spacer()
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}

struct HistoryCardView: View {
    let item: HistoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
            } else {
                ZStack {
                    ThemeColors.surface
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(ThemeColors.accent.opacity(0.6))
                }
                .frame(height: 120)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.rockName)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(ThemeColors.primaryText)
                    .lineLimit(1)
                
                Text(item.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.secondaryText)
            }
            .padding()
        }
        .background(ThemeColors.surface)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
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
