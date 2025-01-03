import Foundation

@MainActor
class CheckListViewModel: ObservableObject {
    @Published var checkList: [CheckList] = []
    @Published var listTitle: String = ""
    @Published var editCheckList: CheckList?
    private let repository: CheckItemRepository

    init(repository: CheckItemRepository) {
        self.repository = repository
    }

    func createCheckItemList() async {
        repository.createCheckList(listTitle: listTitle)
        clearInputTitle()
        await getCheckList()
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
        await getCheckList()
    }

    // 入力用変数の初期化処理
    func clearInputTitle() {
        listTitle = ""
    }

    // リスト作成用タイトル入力欄判定処理
    var isButtonEnable: Bool {
        listTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // チェック項目編集用入力欄判定処理
    var isEditButtonEnable: Bool {
        guard let editCheckList = editCheckList else { return true }
        return listTitle.trimmingCharacters(in: .whitespaces) == editCheckList.title || listTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
