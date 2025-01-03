import Foundation
import SwiftData

@MainActor
class CheckItemViewModel: ObservableObject {
    @Published var checkItemList: [CheckItem] = []
    @Published var inputItemName = ""
    @Published var editItem: CheckItem?
    private let repository: CheckItemRepotitory

    init(repository: CheckItemRepotitory) {
        self.repository = repository
    }

    //チェック項目の追加用処理
    func createCheckItem() async {
        await repository.create(itemName: inputItemName)
        clearInputItemName()
        checkItemList = repository.fetchAll()
    }

    //チェック項目の編集用処理
    func editCheckItemName() async {
        guard let editItem else { return }
        await repository.editItem(targetId: editItem.id, updataName: inputItemName, updataChecked: editItem.checked)
        clearInputItemName()
    }

    //チェック項目のステータス更新用処理
    func updateCheckStatus(for item: CheckItem) async {
        await repository.editStatus(item: item, newCheckedStatus: item.checked)
    }

    //チェック項目の一覧を取得
    func getCheckItems() async {
        checkItemList = repository.fetchAll()
    }

    //チェック項目の削除用処理
    func deleteCheckItem() async {
        guard let editItem else { return }
        do {
            checkItemList = try await repository.delete(targetId: editItem.id)
        } catch {
            print("Failed to delete item: \(error)")
        }
    }

    //入力用変数の初期化処理
    func clearInputItemName() {
        inputItemName = ""
    }
    //チェック項目作成用タイトル入力欄判定処理
    var isButtonEnable: Bool {
        inputItemName.trimmingCharacters(in: .whitespaces) == ""
    }

    //チェック項目編集用入力欄判定処理
    var isEditButtonEnable: Bool {
        let editItemData = editItem!
        return inputItemName.trimmingCharacters(in: .whitespaces) == editItemData.itemName || inputItemName.trimmingCharacters(in: .whitespaces) == ""
    }
}
