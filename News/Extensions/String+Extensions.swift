import Foundation

extension String {
    static let empty = String()
    
    func getFormattedDate(format: String = "MMM d,yyyy") -> String? {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        guard let date = isoFormatter.date(from: self) else {
            return nil
        }

        let displayFormatter = DateFormatter()
        displayFormatter.locale = Locale(identifier: "en_US_POSIX")
        displayFormatter.dateFormat = format

        return displayFormatter.string(from: date)
    }
}
