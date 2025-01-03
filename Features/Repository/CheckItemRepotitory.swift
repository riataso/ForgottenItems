import Foundation
import SwiftData

@MainActor
final class CheckItemRepotitory {
    private let modelContainer = try? ModelContainer(for: CheckItem.self, CheckList.self)

    //チェック項目を追加する処理
    func create(itemName: String) async {
        let checkItem = CheckItem(id: UUID(), itemName: itemName, checked: true)
        modelContainer?.mainContext.insert(checkItem)
        do {
            try modelContainer?.mainContext.save() // 永続化
        } catch {
            print("Failed to create item: \(error)")
        }
    }

    //全データを取得する処理
    func fetchAll() -> [CheckItem] {
        let descriptor = FetchDescriptor<CheckItem>()
        let fetchItems = try? modelContainer?.mainContext.fetch(descriptor)
            guard let fetchItems else {
                //TODO:エラーハンドリング
                print("データ取得エラー")
                return []
            }
            return fetchItems
    }

    //チェック項目を編集するための処理
    func editItem(targetId: UUID, updataName: String, updataChecked: Bool) async {
        guard let editItem = fetchAll().first(where: { $0.id == targetId }) else { return }
        editItem.itemName = updataName
        editItem.checked = updataChecked
        do {
            try modelContainer?.mainContext.save()
        } catch  {
            print("Failed to edit item: \(error)")
        }
    }

    //チェック項目のステータスを更新するための処理
    func editStatus(item: CheckItem, newCheckedStatus: Bool) async {
        item.checked = newCheckedStatus
        do {
            try modelContainer?.mainContext.save()
        } catch {
            print("Failed to update item: \(error)")
        }
    }

    //対象データの情報を取得する処理
    func fetch(targetId: UUID) -> CheckItem? {
        return fetchAll().first(where: { $0.id == targetId })
    }

    //対象データの情報を削除する処理
    func delete(targetId: UUID) async throws -> [CheckItem]  {
        guard let deleteItem = fetchAll().first(where: { $0.id == targetId }) else { return [] }
        modelContainer?.mainContext.delete(deleteItem)
        try modelContainer?.mainContext.save() // 永続化
        return fetchAll()
    }
}

// MARK: チェック項目のリスト処理を拡張によって分離
extension CheckItemRepotitory {
    //チェックリストの作成用処理
    func createCheckList(listTitle: String) {
        let checkList = CheckList(id: UUID(), title: listTitle, checkItems: [])
        modelContainer?.mainContext.insert(checkList)
    }

    //全チェックリストを取得する処理
    func fetchList() -> [CheckList]{
        let descriptor = FetchDescriptor<CheckList>()
        let fetchList = try? modelContainer?.mainContext.fetch(descriptor)
            guard let fetchList else {
                //TODO:エラーハンドリング
                print("データ取得エラー")
                return []
            }
            return fetchList
    }

    //チェックリストの削除用処理
    func deleteList(targetId: UUID) -> [CheckList] {
        guard let deleteItem = fetchList().first(where: { $0.id == targetId }) else { return [] }
        modelContainer?.mainContext.delete(deleteItem)
        return fetchList()
    }

    //チェックリストのリスト名編集用処理
    func editListName(id: UUID, title: String) async {
        guard let editListName = fetchList().first(where: { $0.id == id }) else { return }
        editListName.title = title
        do {
            try modelContainer?.mainContext.save()
        } catch  {
            print("Failed to edit item: \(error)")
        }
    }
}
