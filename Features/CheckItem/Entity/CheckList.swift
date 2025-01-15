import Foundation
import SwiftData

@Model
class CheckList: Identifiable {
    var id: UUID
    var title: String
    var date: Date
    var isEditingAlarm: Bool

    init(id: UUID, title: String, date: Date, isEnabled: Bool) {
        self.id = id
        self.title = title
        self.date = date
        self.isEditingAlarm = isEnabled
    }
}
