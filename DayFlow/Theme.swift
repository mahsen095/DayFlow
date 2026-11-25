import SwiftUI

enum DF {
    static let bg = Color(hex: 0xF8e580)
    static let paper = Color(hex: 0xFFFEFC)
    static let ink = Color(hex: 0x282139)
    static let muted = Color(hex: 0x96909F)
    static let purple = Color(hex: 0x8065D9)
    static let violet = Color(hex: 0xA38BEE)
    static let lavender = Color(hex: 0xEDE6FF)
    static let peach = Color(hex: 0xFFE1D4)
    static let coral = Color(hex: 0xF28B75)
    static let mint = Color(hex: 0xD9F1E5)
    static let green = Color(hex: 0x50AC83)
    static let yellow = Color(hex: 0xF5D98A)
    static let navy = Color(hex: 0x302747)
    static let line = Color(hex: 0xEEE9E5)
    static let blueColor = Color(hex: 0x589BD7)
}

extension Color {
    init(hex: UInt) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 255) / 255,
            green: Double((hex >> 8) & 255) / 255,
            blue: Double(hex & 255) / 255,
            opacity: 1
        )
    }
}
