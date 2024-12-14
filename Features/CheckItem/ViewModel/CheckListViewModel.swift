import Foundation

class CheckListViewModel: ObservableObject {
    @Published var checkList: [CheckList] = []
    @Published var listTitle: String = ""

    func createCheckItemList() {
        let newCheckList: CheckList = .init(id:UUID(), title: listTitle, checkItems: [])
        checkList += [newCheckList]
        listTitle = ""
    }

    func rowRemoveCheckList(offsets: IndexSet) {
        checkList.remove(atOffsets: offsets)
    }
    //リスト作成用タイトル入力欄判定処理
    var isButtonEnable: Bool {
        listTitle.trimmingCharacters(in: .whitespaces) == ""
    }
}
