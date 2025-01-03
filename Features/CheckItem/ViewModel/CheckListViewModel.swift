import Foundation

@MainActor
class CheckListViewModel: ObservableObject {
    @Published var checkList: [CheckList] = []
    @Published var listTitle: String = ""
    @Published var editCheckList: CheckList?
    private let repository: CheckItemRepotitory

    init(repository: CheckItemRepotitory) {
        self.repository = repository
    }

    func createCheckItemList()  async {
        repository.createCheckList(listTitle: listTitle)
        checkList = repository.fetchList()
    }

    func getCheckList() async {
        checkList = repository.fetchList()
    }

    func deleteCheckList() async {
        guard let editCheckList else { return }
        checkList = repository.deleteList(targetId: editCheckList.id)
    }

    func editCheckListName() async {
        guard let editCheckList else { return }
        await repository.editListName(id: editCheckList.id, title: listTitle)
        clearInputTitle()
    }

    //入力用変数の初期化処理
    func clearInputTitle() {
        listTitle = ""
    }
    //リスト作成用タイトル入力欄判定処理
    var isButtonEnable: Bool {
        listTitle.trimmingCharacters(in: .whitespaces) == ""
    }

    //チェック項目編集用入力欄判定処理
    var isEditButtonEnable: Bool {
        let editListName = editCheckList
        return listTitle.trimmingCharacters(in: .whitespaces) == editListName?.title || listTitle.trimmingCharacters(in: .whitespaces) == ""
    }
}
