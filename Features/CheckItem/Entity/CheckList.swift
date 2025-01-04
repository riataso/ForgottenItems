import Foundation
import SwiftData

@Model
class CheckList: Identifiable {
    var id: UUID
    var title: String

    init(id: UUID, title: String) {
        self.id = id
        self.title = title
    }
}
