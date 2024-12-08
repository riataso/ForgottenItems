import Foundation

class CheckListViewModel: ObservableObject {
    @Published var checkList: [CheckList] = []
    var titleList: String = ""

    func createCheckItemList() {
        let newCheckList: CheckList = .init(id:UUID(), title: titleList, checkItems: [])
        checkList += [newCheckList]
    }

    func rowRemoveCheckList(offsets: IndexSet) {
        checkList.remove(atOffsets: offsets)
    }
}
