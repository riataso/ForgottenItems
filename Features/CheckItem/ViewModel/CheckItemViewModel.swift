import Foundation
import SwiftData

@MainActor
class CheckItemViewModel: ObservableObject {
    @Published var checkItemList: [CheckItem] = []
    @Published var inputItemName = ""
    @Published var editItem: CheckItem?
    private let repository: CheckItemRepository
    var checkListID: UUID
    var checkListTitle: String

    init(repository: CheckItemRepository, checkList: CheckList) {
        self.repository = repository
        self.checkListID = checkList.id
        self.checkListTitle = checkList.title
    }

    // チェック項目の追加用処理
    func createCheckItem() async {
        await repository.create(itemName: inputItemName, listID: checkListID)
        clearInputItemName()
        await getCheckItems()
    }

    // チェック項目の編集用処理
    func editCheckItemName() async {
        guard let editItem else { return }
        await repository.editItem(targetId: editItem.id, updatedName: inputItemName, updatedChecked: editItem.checked)
        clearInputItemName()
        await getCheckItems()
    }

    // チェック項目のステータス更新用処理
    func updateCheckStatus(for item: CheckItem) async {
        await repository.editStatus(item: item, newCheckedStatus: item.checked)
    }

    // チェック項目の一覧を取得
    func getCheckItems() async {
        checkItemList = repository.fetchAll(for: checkListID)
    }

    // チェック項目の削除用処理
    func deleteCheckItem() async {
        guard let editItem else { return }
        do {
            try await repository.delete(targetId: editItem.id)
            await getCheckItems()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }

    // 入力用変数の初期化処理
    func clearInputItemName() {
        inputItemName = ""
    }

    // チェック項目作成用タイトル入力欄判定処理
    var isButtonEnable: Bool {
        inputItemName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // チェック項目編集用入力欄判定処理
    var isEditButtonEnable: Bool {
        guard let editItem = editItem else { return true }
        return inputItemName.trimmingCharacters(in: .whitespaces) == editItem.itemName || inputItemName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
