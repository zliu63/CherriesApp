import Foundation

struct Quest: Identifiable {
    let id: UUID
    var title: String
    var subtitle: String
    var progress: Double
    var isActive: Bool

    init(id: UUID = UUID(), title: String, subtitle: String, progress: Double = 0, isActive: Bool = true) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.progress = min(max(progress, 0), 1)
        self.isActive = isActive
    }

    var progressPercentage: Int {
        Int(progress * 100)
    }
}
