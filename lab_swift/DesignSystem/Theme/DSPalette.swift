import UIKit

struct DSPalette {
    let background: UIColor
    let surface: UIColor

    let primary: UIColor

    let onPrimary: UIColor

    let secondary: UIColor

    let textPrimary: UIColor
    let textSecondary: UIColor

    let error: UIColor
    let errorText: UIColor

    let border: UIColor
    let separator: UIColor

    let statusPositive: UIColor
    let statusNegative: UIColor

    let iconMuted: UIColor

    static func warm() -> DSPalette {
        DSPalette(
            background: UIColor(red: 0.935, green: 0.925, blue: 0.878, alpha: 1),
            surface: UIColor(red: 0.902, green: 0.882, blue: 0.831, alpha: 1),
            primary: UIColor(red: 0.769, green: 0.584, blue: 0.416, alpha: 1),
            onPrimary: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
            secondary: UIColor(red: 0.463, green: 0.118, blue: 0.188, alpha: 1),
            textPrimary: UIColor(red: 0.239, green: 0.204, blue: 0.169, alpha: 1),
            textSecondary: UIColor(red: 0.541, green: 0.498, blue: 0.451, alpha: 1),
            error: UIColor(red: 0.780, green: 0.157, blue: 0.157, alpha: 1),
            errorText: UIColor(red: 0.463, green: 0.118, blue: 0.188, alpha: 1),
            border: UIColor(red: 0.886, green: 0.835, blue: 0.784, alpha: 1),
            separator: UIColor(red: 0.910, green: 0.875, blue: 0.831, alpha: 1),
            statusPositive: UIColor(red: 0.180, green: 0.490, blue: 0.196, alpha: 1),
            statusNegative: UIColor(red: 0.780, green: 0.157, blue: 0.157, alpha: 1),
            iconMuted: UIColor(red: 0.659, green: 0.596, blue: 0.533, alpha: 1)
        )
    }
    
    static func dark() -> DSPalette {
        DSPalette(
            background: UIColor(red: 0.070, green: 0.070, blue: 0.082, alpha: 1),
            surface: UIColor(red: 0.115, green: 0.115, blue: 0.130, alpha: 1),
            primary: UIColor(red: 0.714, green: 0.529, blue: 0.984, alpha: 1),
            onPrimary: UIColor(red: 0.090, green: 0.078, blue: 0.110, alpha: 1),
            secondary: UIColor(red: 0.650, green: 0.650, blue: 0.700, alpha: 1),
            textPrimary: UIColor(red: 0.965, green: 0.965, blue: 0.980, alpha: 1),
            textSecondary: UIColor(red: 0.700, green: 0.700, blue: 0.760, alpha: 1),
            error: UIColor(red: 0.600, green: 0.430, blue: 0.860, alpha: 1),
            errorText: UIColor(red: 0.600, green: 0.430, blue: 0.860, alpha: 1),
            border: UIColor(red: 0.220, green: 0.220, blue: 0.260, alpha: 1),
            separator: UIColor(red: 0.170, green: 0.170, blue: 0.200, alpha: 1),
            statusPositive: UIColor(red: 0.263, green: 0.902, blue: 1.000, alpha: 1),
            statusNegative: UIColor(red: 0.420, green: 0.300, blue: 0.690, alpha: 1),
            iconMuted: UIColor(red: 0.600, green: 0.430, blue: 0.860, alpha: 1)
        )
    }
}
