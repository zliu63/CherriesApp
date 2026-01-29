import SwiftUI

extension Color {
    init(hex: String) {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppColors {
    static let primary = Color(hex: "E91E63")
    static let secondary = Color(hex: "00B4D8")
    static let accent = Color(hex: "4CAF50")

    static let questGradientStart = Color(hex: "00D9B5")
    static let questGradientMid = Color(hex: "00B4D8")
    static let questGradientEnd = Color(hex: "4C8BF5")

    static let splashGradientStart = Color(hex: "FF6B8A")
    static let splashGradientEnd = Color(hex: "FF8E72")

    static let addButtonStart = Color(hex: "E040FB")
    static let addButtonEnd = Color(hex: "EA80FC")

    static let streakOrange = Color(hex: "FF6B35")
    static let background = Color(hex: "F8F9FA")

    static let achievementOrange = Color(hex: "FFA726")
    static let achievementPurple = Color(hex: "7E57C2")
    static let achievementTeal = Color(hex: "26A69A")
}
