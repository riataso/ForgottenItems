import Foundation

class CheckItemViewModel: ObservableObject {
    @Published var checkItemName: String = ""
    var checkItemList: [CheckItem] = []

    func createCheckItem() {
        var checkItem: CheckItem = .init(id: UUID(), itemName: checkItemName, checked: false)
        checkItemList += [checkItem]
    }

    func deleteCheckItem(at id: UUID) {
        let newCheckItems = checkItemList.filter({ $0.id != id })
        checkItemList = newCheckItems
    }
}
