import SwiftUI

/// roadside-forest green with a rest-sign lime accent
enum Theme {
    static let background = Color(red: 0.082, green: 0.11, blue: 0.071)
    static let accent = Color(red: 0.545, green: 0.765, blue: 0.29)
    static let ink = Color(red: 0.945, green: 0.969, blue: 0.918)
    static let cardBackground = Color(red: 0.153, green: 0.18, blue: 0.141)
    static let secondaryInk = Color(red: 0.788, green: 0.812, blue: 0.761)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headingFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 18
}

extension View {
    func themedBackground() -> some View {
        self.background(Theme.background.ignoresSafeArea())
    }
}
