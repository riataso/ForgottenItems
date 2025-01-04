import Foundation
import SwiftData

@MainActor
final class CheckItemRepository {
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: CheckItem.self, CheckList.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    // チェック項目を追加する処理
    func create(itemName: String, listID: UUID) async {
        let checkItem = CheckItem(id: UUID(), itemName: itemName, checked: true, listID: listID)
        modelContainer.mainContext.insert(checkItem)
        do {
            try modelContainer.mainContext.save() // 永続化
        } catch {
            print("Failed to create item: \(error)")
        }
    }

    // 特定のCheckListに属する全データを取得する処理
    func fetchAll(for listID: UUID) -> [CheckItem] {
        let predicate = #Predicate { (item: CheckItem) in
            item.listID == listID
        }
        let descriptor = FetchDescriptor<CheckItem>(predicate: predicate)
        let fetchItems = try? modelContainer.mainContext.fetch(descriptor)
        guard let fetchItems else { return [] }
        return fetchItems
    }

    // チェック項目を編集する処理
    func editItem(targetId: UUID, updatedName: String, updatedChecked: Bool) async {
        let descriptor = FetchDescriptor<CheckItem>(predicate: #Predicate { $0.id == targetId })
        guard let editItem = (try? modelContainer.mainContext.fetch(descriptor))?.first else { return }
        editItem.itemName = updatedName
        editItem.checked = updatedChecked
        do {
            try modelContainer.mainContext.save()
        } catch {
            print("Failed to edit item: \(error)")
        }
    }

    // チェック項目のステータスを更新する処理
    func editStatus(item: CheckItem, newCheckedStatus: Bool) async {
        item.checked = newCheckedStatus
        do {
            try modelContainer.mainContext.save()
        } catch {
            print("Failed to update item: \(error)")
        }
    }

    // 対象データの情報を削除する処理
    func delete(targetId: UUID) async throws {
        let descriptor = FetchDescriptor<CheckItem>(predicate: #Predicate { $0.id == targetId })
        guard let deleteItem = (try? modelContainer.mainContext.fetch(descriptor))?.first else { return }
        modelContainer.mainContext.delete(deleteItem)
        try modelContainer.mainContext.save() // 永続化
    }
}

//チェックリスト周りの処理を拡張によって分割
extension CheckItemRepository {
    // チェックリストの作成用処理
    func createCheckList(listTitle: String) {
        let checkList = CheckList(id: UUID(), title: listTitle)
        modelContainer.mainContext.insert(checkList)
        do {
            try modelContainer.mainContext.save()
        } catch {
            print("Failed to create checklist: \(error)")
        }
    }

    // 全チェックリストを取得する処理
    func fetchList() -> [CheckList] {
        let descriptor = FetchDescriptor<CheckList>()
        let fetchList = try? modelContainer.mainContext.fetch(descriptor)
        guard let fetchList else {
            print("データ取得エラー")
            return []
        }
        return fetchList
    }

    // チェックリストの削除用処理
    func deleteList(targetId: UUID) -> [CheckList] {
        // 関連するCheckItemも削除
        let itemDescriptor = FetchDescriptor<CheckItem>(predicate: #Predicate { $0.listID == targetId })
        if let itemsToDelete = try? modelContainer.mainContext.fetch(itemDescriptor) {
            for item in itemsToDelete {
                modelContainer.mainContext.delete(item)
            }
        }

        let descriptor = FetchDescriptor<CheckList>(predicate: #Predicate { $0.id == targetId })
        guard let deleteItem = (try? modelContainer.mainContext.fetch(descriptor))?.first else { return [] }
        modelContainer.mainContext.delete(deleteItem)
        do {
            try modelContainer.mainContext.save()
        } catch {
            print("Failed to delete checklist: \(error)")
        }
        return fetchList()
    }

    // チェックリストのリスト名編集用処理
    func editListName(id: UUID, title: String) async {
        let descriptor = FetchDescriptor<CheckList>(predicate: #Predicate { $0.id == id })
        guard let editListName = (try? modelContainer.mainContext.fetch(descriptor))?.first else { return }
        editListName.title = title
        do {
            try modelContainer.mainContext.save()
        } catch {
            print("Failed to edit checklist: \(error)")
        }
    }
}
