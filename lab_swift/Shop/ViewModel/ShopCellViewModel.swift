import Foundation

struct ShopCellViewModel: Equatable, Identifiable {
    let id: String
    let title: String
    let imageURL: URL?
    let isOpen: Bool
    let statusText: String
}

enum ShopCellViewModelMapper {
    static func map(_ shops: [Shop], now: Date = Date()) -> [ShopCellViewModel] {
        shops.map { map($0, now: now) }
    }

    static func map(_ shop: Shop, now: Date = Date()) -> ShopCellViewModel {
        let isOpen = ShopOpenStatusCalculator.isOpen(workHours: shop.workHours, now: now)

        return ShopCellViewModel(
            id: shop.id,
            title: shop.name,
            imageURL: shop.imageURL,
            isOpen: isOpen,
            statusText: isOpen ? "Открыто" : "Закрыто"
        )
    }
}

private enum ShopOpenStatusCalculator {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = .current
        return formatter
    }()

    static func isOpen(
        workHours: String,
        now: Date,
        calendar: Calendar = .current
    ) -> Bool {
        let parts = workHours
            .components(separatedBy: "-")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        guard parts.count == 2 else {
            return false
        }

        guard
            let openComponents = timeComponents(from: parts[0]),
            let closeComponents = timeComponents(from: parts[1]),
            let openHour = openComponents.hour,
            let openMinute = openComponents.minute,
            let closeHour = closeComponents.hour,
            let closeMinute = closeComponents.minute,
            let openDate = calendar.date(bySettingHour: openHour, minute: openMinute, second: 0, of: now),
            let closeDate = calendar.date(bySettingHour: closeHour, minute: closeMinute, second: 0, of: now)
        else {
            return false
        }

        if closeDate >= openDate {
            return now >= openDate && now <= closeDate
        }

        return now >= openDate || now <= closeDate
    }

    private static func timeComponents(from value: String) -> DateComponents? {
        guard let date = formatter.date(from: value) else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: date)
        guard let hour = components.hour, let minute = components.minute else {
            return nil
        }

        return DateComponents(hour: hour, minute: minute)
    }
}
