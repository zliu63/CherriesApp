import SwiftUI

struct Achievement: Identifiable {
    let id: UUID
    var title: String
    var icon: String
    var color: Color
    var isUnlocked: Bool

    init(id: UUID = UUID(), title: String, icon: String, color: Color, isUnlocked: Bool = true) {
        self.id = id
        self.title = title
        self.icon = icon
        self.color = color
        self.isUnlocked = isUnlocked
    }
}
