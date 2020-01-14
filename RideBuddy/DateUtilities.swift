import Foundation

// Like ISO8601, but not quite
// private var rideJournalDateFormatter: ISO8601DateFormatter?
private var rideJournalDateFormatter: DateFormatter?

extension String {
    /// Convert ourselves (a String) into Date in the local time
    /// zone.  The date format is 2020-01-13T00:00:00Z, so
    /// mostly ISO8601. But instead of using that time realtive to
    /// Zulu, it uses the local time zone for that.
    
    func rideJournalDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.remove(.withColonSeparatorInTimeZone)
        formatter.timeZone = .current
        let date = formatter.date(from: self)
        
        return date
    }
}
