import Foundation
import SwiftData

@Model
class CheckItem: Identifiable {
    var id: UUID
    var itemName: String
    var checked: Bool
    var listID: UUID

    init(id: UUID, itemName: String, checked: Bool, listID: UUID) {
        self.id = id
        self.itemName = itemName
        self.checked = checked
        self.listID = listID
    }
}
