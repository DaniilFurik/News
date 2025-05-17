import Foundation

extension String {
    static let empty = String()
    
    func getFormattedDate(format: String = GlobalConstants.Strings.defaultDateFormat) -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        guard let date = isoFormatter.date(from: self) else {
            return nil
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: GlobalConstants.Strings.defaultLocale)
        displayFormatter.dateFormat = format

        return displayFormatter.string(from: date)
    }
}
