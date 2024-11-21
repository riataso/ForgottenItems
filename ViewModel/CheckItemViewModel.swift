import Foundation

class CheckItemViewModel: ObservableObject {
    @Published var checkItemName: String = ""
    var checkItemList: [CheckItem] = []

    func createCheckItem() {
        var checkItem: CheckItem = .init(id: UUID(), itemName: checkItemName, checked: false)
        checkItemList += [checkItem]
    }
}
