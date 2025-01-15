import Foundation

@MainActor
@Observable
class CheckListViewModel {
    var checkList: [CheckList] = []
    var listTitle: String = ""
    var editCheckList: CheckList?
    var selectedDate: Date = Date()
    var selectedTime: Date = Date()
    private let repository: CheckItemRepository


    init(repository: CheckItemRepository) {
        self.repository = repository
    }

    func createCheckItemList() async {
        /// 通知設定用のDate形式に整形するため、日付と時間を一つにする
        guard let combinedDate = Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: selectedTime), minute: Calendar.current.component(.minute, from: selectedTime), second: 0, of: selectedDate
        ) else {
            //TODO: エラーハンドリング
            return
        }
        guard let listID = repository.createCheckList(listTitle: listTitle, date: combinedDate) else { return }
        NotificationSender.shared.scheduleNotification(notificationDate: combinedDate, id: listID, listTitle: listTitle)
        clearInputTitle()
        await getCheckList()
    }

    /// チェックリストを取得
    func getCheckList() async {
        checkList = repository.fetchList()
    }

    /// 選択されたチェックリストを削除
    func deleteCheckList() async {
        guard let editCheckList else { return }
        checkList = repository.deleteList(targetId: editCheckList.id)
        NotificationSender.shared.cancelNotification(identifier: editCheckList.id)
    }

    /// 日付と時間を分割して設定（編集時に使用）
    func splitDateTime(editDate: Date) {
        let calendar = Calendar.current
        selectedDate = calendar.startOfDay(for: editDate)
        selectedTime = calendar.date(bySettingHour: calendar.component(.hour, from: editDate),
                                     minute: calendar.component(.minute, from: editDate),
                                     second: calendar.component(.second, from: editDate),
                                     of: Date()) ?? Date()
    }

    /// チェックリストを編集し、通知を更新
    func editCheckList() async {
        guard let editCheckList else { return }
        // 通知設定用のDate形式に整形するため、日付と時間を一つにする
        do {
            let combinedDate = try combineSelectedDateAndTime()
            await repository.editListName(id: editCheckList.id, updateTitle: listTitle, updateAlarmDate: combinedDate)
            clearInputTitle()
            await getCheckList()
            // 通知を更新
            NotificationSender.shared.updateNotification(notificationDate: combinedDate, identifier: editCheckList.id, listTitle: listTitle)
        } catch {
            // エラーハンドリング
            print("エラーが発生しました: \(error.localizedDescription)")
        }
    }

    /// 日付と時間を組み合わせて Date を作成
    private func combineSelectedDateAndTime() throws -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: selectedTime)
        components.hour = timeComponents.hour
        components.minute = timeComponents.minute
        components.second = 0

        guard let combinedDate = calendar.date(from: components) else {
            throw NSError(domain: "DateCombinationError", code: -1, userInfo: [NSLocalizedDescriptionKey: "日時の組み合わせに失敗しました"])
        }
        return combinedDate
    }

    // 入力用変数の初期化処理
    func clearInputTitle() {
        listTitle = ""
    }

    /// リスト作成ボタンの有効/無効を判定
    var isButtonEnable: Bool {
        listTitle.trimmingCharacters(in: .whitespaces).isEmpty
    }

    /// リスト編集保存ボタンの有効/無効を判定
    var isEditButtonDisabled: Bool {
        guard let editCheckList else { return true }
        do {
            let combinedDate = try combineSelectedDateAndTime()
            let isTitleChanged = listTitle.trimmingCharacters(in: .whitespacesAndNewlines) != editCheckList.title
            let isDateChanged = editCheckList.date != combinedDate
            let isTitleEmpty = listTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            // タイトルが空でない、かつタイトルまたは日付が変更された場合にボタンを有効化
            return isTitleEmpty || (!isTitleChanged && !isDateChanged)
        } catch {
            return true
        }
    }
}
