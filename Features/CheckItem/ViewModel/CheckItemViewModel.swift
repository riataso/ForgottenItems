import Foundation

class CheckItemViewModel: ObservableObject {
    @Published var checkItemList: [CheckItem] = []
    @Published var editItemId: UUID?

    func createCheckItem() {
        editFinish()
        let checkItem: CheckItem = .init(id: UUID(), itemName: "", checked: true)
        checkItemList += [checkItem]
        editItemId = checkItem.id
    }

    func rowRemove(offsets: IndexSet) {
        checkItemList.remove(atOffsets: offsets)
    }

    func editCheckItem(id: UUID, itemName: String) {
        if let index = checkItemList.firstIndex(where: { $0.id == id }) {
            checkItemList[index].itemName = itemName
        }
    }

    func editFinish() {
        editItemId = nil
        checkItemList.removeAll { $0.itemName.trimmingCharacters(in: .whitespaces).isEmpty }
    }

}
