import SwiftUI

// ThemeColors struct will be the single source of truth for app theme colors.
// It uses the hex initializer defined below.
struct ThemeColors {
    // A deep, warm charcoal. The foundation of our dark, premium theme.
    static let background = colorFrom(hex: "#1A1A1A")

    // A slightly lighter charcoal for card surfaces and modals, creating subtle depth.
    static let surface = colorFrom(hex: "#2A2A2A")

    // A rich, confident terracotta. Draws attention without being jarring.
    static let primaryAction = colorFrom(hex: "#D95F43")

    // A soft, warm off-white for maximum readability and a less harsh feel than pure white.
    static let primaryText = colorFrom(hex: "#F5F5F5")

    // A medium gray with excellent contrast against our dark backgrounds.
    static let secondaryText = colorFrom(hex: "#9E9E9E")

    // A muted, calming sage green for icons and secondary highlights.
    static let accent = colorFrom(hex: "#5C8374")
    
    // A vibrant green for success states.
    static let success = colorFrom(hex: "#44bd32")

    // A standard red for error states.
    static let error = colorFrom(hex: "#e84118")

    // Private helper function to convert hex to Color, scoped to this struct.
    // This avoids conflicts with any other `Color(hex:)` initializers in the project.
    private static func colorFrom(hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0) // Default to black if hex is invalid
        }

        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
