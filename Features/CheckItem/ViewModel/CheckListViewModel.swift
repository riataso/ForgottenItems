import Foundation

@MainActor
class CheckListViewModel: ObservableObject {
    @Published var checkList: [CheckList] = []
    @Published var listTitle: String = ""
    @Published var editCheckList: CheckList?
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: Date = Date()
    private let repository: CheckItemRepository

    init(repository: CheckItemRepository) {
        self.repository = repository
    }

    func createCheckItemList() async {
        // 通知設定用のDate形式に整形するため、日付と時間を一つにする
        guard let combinedDate = Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: selectedTime), minute: Calendar.current.component(.minute, from: selectedTime), second: 0, of: selectedDate
        ) else {
            //TODO: エラーハンドリング
            return
        }
        repository.createCheckList(listTitle: listTitle, date: combinedDate)
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

    //保存されているアラーム用日付データをV編集できるように日付・時間で分割
    func splitDateTime(editDate: Date) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: editDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: editDate)

        if let date = calendar.date(from: dateComponents), let time = calendar.date(from: timeComponents) {
            selectedDate = date
            selectedTime = time
        }
    }

    func editCheckList() async {
        guard let editCheckList else { return }
        // 通知設定用のDate形式に整形するため、日付と時間を一つにする
        guard let combinedUpdateDate = Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: selectedTime), minute: Calendar.current.component(.minute, from: selectedTime), second: 0, of: selectedDate
        ) else {
            //TODO: エラーハンドリング
            return
        }
        await repository.editListName(id: editCheckList.id, updateTitle: listTitle, updateAlarmDate:  combinedUpdateDate)
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
        guard let combinedDate = Calendar.current.date(
            bySettingHour: Calendar.current.component(.hour, from: selectedTime),
            minute: Calendar.current.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate

        ) else {
            fatalError("Failed to combine date and time")
        }
        return (listTitle.trimmingCharacters(in: .whitespaces) == editCheckList.title && listTitle.trimmingCharacters(in: .whitespaces).isEmpty) || editCheckList.date == combinedDate
    }
}
