import Foundation

struct CheckItem: Identifiable {
    var id: UUID
    var itemName: String
    var checked: Bool

    init(id: UUID, itemName: String, checked: Bool) {
        self.id = id
        self.itemName = itemName
        self.checked = checked
    }
}
