import Foundation

struct CheckList: Identifiable  {
    var id: UUID
    var title: String
    var checkItems: [CheckItem]

    init(id: UUID, title: String, checkItems: [CheckItem]) {
        self.id = id
        self.title = title
        self.checkItems = checkItems
    }
}
