import Foundation
import SwiftData

@MainActor
@Observable
class CheckItemViewModel {
    var checkItemList: [CheckItem] = []
    var inputItemName = ""
    var editItem: CheckItem?
    var updateStatus = false
    var checkList: CheckList
    private let repository: CheckItemRepository
    var checkListID: UUID
    var checkListTitle: String

    init(repository: CheckItemRepository, checkList: CheckList) {
        self.repository = repository
        self.checkListID = checkList.id
        self.checkListTitle = checkList.title
        self.checkList = checkList
    }

    /// チェック項目の追加用処理
    func createCheckItem() async {
        await repository.create(itemName: inputItemName, listID: checkListID)
        clearInputItemName()
        await getCheckItems()
    }

    /// チェック項目の編集用処理
    func editCheckItemName() async {
        guard let editItem else { return }
        await repository.editItem(targetId: editItem.id, updatedName: inputItemName, updatedChecked: editItem.checked)
        clearInputItemName()
        await getCheckItems()
    }

    /// チェック項目のステータス更新用処理
    func updateCheckStatus(for item: CheckItem) async {
        await repository.editStatus(item: item, newCheckedStatus: !item.checked)
        // 全アイテムがチェック済かを確認
        if hasUncheckedItems(item: item) {
            // チェックリストのアラームステータスをFalseにする
            await repository.editListStatus(id: item.listID, newAlarmStatus: false)
            // 通知をキャンセル
            NotificationSender.shared.cancelNotification(identifier: item.listID)

            // チェックリストのアラームステータスがFalseの場合
        } else if !checkList.isEditingAlarm {
            print("ステータス変更の処理が呼び出されました。")
            // チェックリストのアラームステータスをTrueにする
            await repository.editListStatus(id: item.listID, newAlarmStatus: true)
            // 通知を再スケジュール（新しい通知を設定）
            NotificationSender.shared.scheduleNotification(notificationDate: checkList.date, id: item.listID, listTitle: checkList.title)
        }
        guard let updateList = repository.fetchItemList(id: item.listID) else { return }
        checkList = updateList
    }

    /// 全チェックアイテムのステータスがTrueかを確認
    func hasUncheckedItems(item: CheckItem) -> Bool{
        let items = repository.fetchAll(for: item.listID)
        return items.allSatisfy { $0.checked  }
    }


    /// チェック項目の一覧を取得
    func getCheckItems() async {
        checkItemList = repository.fetchAll(for: checkListID)
    }

    /// チェック項目の削除用処理
    func deleteCheckItem() async {
        guard let editItem else { return }
        do {
            try await repository.delete(targetId: editItem.id)
            clearInputItemName()
            await getCheckItems()
        } catch {
            print("Failed to delete item: \(error)")
        }
    }

    /// 入力用変数の初期化処理
    func clearInputItemName() {
        inputItemName = ""
    }

    /// チェック項目作成用タイトル入力欄判定処理
    var isButtonEnable: Bool {
        inputItemName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// チェック項目編集用入力欄判定処理
    var isEditButtonEnable: Bool {
        guard let editItem = editItem else { return true }
        return inputItemName.trimmingCharacters(in: .whitespaces) == editItem.itemName || inputItemName.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

