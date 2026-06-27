import Foundation
import SwiftUI

extension Color {
    static let playerBackgroundTop = Color(red: 0.09, green: 0.10, blue: 0.12)
    static let playerBackgroundBottom = Color(red: 0.73, green: 0.75, blue: 0.76)
    static let shellTop = Color(red: 0.93, green: 0.94, blue: 0.93)
    static let shellBottom = Color(red: 0.63, green: 0.65, blue: 0.67)
    static let shellShadow = Color(red: 0.20, green: 0.22, blue: 0.24)
    static let screenGlass = Color(red: 0.03, green: 0.05, blue: 0.06)
    static let screenTint = Color(red: 0.74, green: 0.91, blue: 0.88)
    static let screenMuted = Color(red: 0.46, green: 0.57, blue: 0.55)
    static let screenHighlight = Color(red: 0.81, green: 0.95, blue: 0.93)
    static let wheelSurface = Color(red: 0.91, green: 0.91, blue: 0.89)
    static let wheelInner = Color(red: 0.70, green: 0.71, blue: 0.71)
    static let controlInk = Color(red: 0.26, green: 0.28, blue: 0.31)
}

extension Font {
    static let screenTitle = Font.system(size: 18, weight: .semibold, design: .monospaced)
    static let screenBody = Font.system(size: 14, weight: .medium, design: .rounded)
    static let screenSmall = Font.system(size: 11, weight: .medium, design: .monospaced)
}

enum DurationText {
    static func string(from duration: TimeInterval?) -> String {
        guard let duration else {
            return "--:--"
        }

        let totalSeconds = Int(duration.rounded())
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}
