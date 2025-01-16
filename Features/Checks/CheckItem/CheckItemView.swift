import SwiftUI

struct CheckItemView: View {
    @State var viewModel: CheckItemViewModel
    @State var createCheckItemView: Bool = false
    @State var editCheckItemView: Bool = false

    init(checkList: CheckList) {
        _viewModel = State(wrappedValue: CheckItemViewModel(repository: CheckItemRepository(), checkList: checkList))
    }

    var body: some View {
        NavigationStack {
            VStack {
                List($viewModel.checkItemList) { $item in
                    HStack(spacing: 16) {
                        // チェックボックスイメージ（ボタンを削除）
                        Image(systemName: item.checked ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 24))
                            .foregroundColor(item.checked ?  Color("CheckIconColor") : .gray)
                        // テキスト
                        Text(item.itemName)
                            .font(.body)
                            .foregroundColor(item.checked ? .secondary : .primary)
                            .strikethrough(item.checked, color: .secondary)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Spacer()

                        // 右側の矢印イメージ（ボタンを削除）
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                    // HStack全体のタップジェスチャー
                    .onTapGesture {
                        viewModel.editItem = item
                        viewModel.inputItemName = item.itemName
                        viewModel.updateStatus = item.checked
                        editCheckItemView.toggle()
                    }
                    .background(
                        Color(UIColor.secondarySystemGroupedBackground)
                    )
                    .cornerRadius(8)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
            }
            .listStyle(InsetGroupedListStyle())
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(viewModel.checkListTitle)
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        createCheckItemView.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $createCheckItemView) {
                CreateCheckItemView(viewModel: viewModel)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $editCheckItemView) {
                EditCheckItemView(viewModel: viewModel)
                    .presentationDragIndicator(.visible)
            }
            .task {
                await viewModel.getCheckItems()
            }
        }
    }
}

// チェック項目作成ビュー
struct CreateCheckItemView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: CheckItemViewModel

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("項目名")) {
                    TextField("持ち物チェック対象を入力", text: $viewModel.inputItemName)
                        .textFieldStyle(PlainTextFieldStyle())
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("チェック項目を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.clearInputItemName()
                        dismiss()
                    } label: {
                        Text("キャンセル")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.createCheckItem()
                            dismiss()
                        }
                    } label: {
                        Text("追加")
                            .foregroundColor(viewModel.isButtonEnable ? .gray : .accentColor)
                    }
                    .disabled(viewModel.isButtonEnable)
                }
            }
        }
    }
}

// チェック項目編集ビュー
struct EditCheckItemView: View {
    @Environment(\.dismiss) var dismiss
    @State var viewModel: CheckItemViewModel

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("項目名")) {
                    TextField("持ち物チェック対象を入力", text: $viewModel.inputItemName)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                Button {
                    Task {
                        await viewModel.updateCheckStatus(for: viewModel.editItem!)
                        dismiss()
                        viewModel.clearInputItemName()
                    }
                } label: {
                    Text(viewModel.editItem?.checked == true ? "チェック項目を未チェックにする" : "チェック項目をチェック済みにする")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                Button {
                    Task {
                        await viewModel.deleteCheckItem()
                        dismiss()
                    }
                } label: {
                    Text("チェック項目を削除")
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("チェック項目を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.clearInputItemName()
                        dismiss()
                    } label: {
                        Text("キャンセル")

                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.editCheckItemName()
                            dismiss()
                        }
                    } label: {
                        Text("保存")
                    }
                    .disabled(viewModel.isEditButtonEnable)
                }
            }
        }
    }
}
