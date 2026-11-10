import Foundation

/// Presentation-owned lookup boundary. English source text is the safe fallback;
/// iOS resolves Spanish (Mexico) from the app bundle when that language is selected.
public enum AppCopy {
    public static func text(_ key: String) -> String {
        Bundle.main.localizedString(forKey: key, value: key, table: "Localizable")
    }
}
