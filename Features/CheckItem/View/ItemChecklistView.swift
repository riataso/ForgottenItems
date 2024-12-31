import SwiftUI

struct ItemChecklistView: View {
    @StateObject var viewModel = CheckItemViewModel(repository: CheckItemRepotitory())
    @State var chekeListTitle: String
    @State var createCheckItemView: Bool = false
    @State var editCheckItemView: Bool = false

    var body: some View {

        NavigationStack(){
            VStack {
                List($viewModel.checkItemList) { $item in
                    HStack {
                        Text(item.itemName)
                        Toggle("",isOn: $item.checked)
                            .onChange(of: item.checked) {
                                Task {
                                    await viewModel.updateCheckStatus(for: item)
                                }
                            }
                    }
                    .listRowBackground(item.checked ? Color.white : Color.gray.opacity(0.7))
                    .animation(.easeInOut, value: item.checked)
                    //編集画面に遷移
                    .onTapGesture {
                        viewModel.editItem = item
                        viewModel.inputItemName = item.itemName
                        editCheckItemView.toggle()
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text(chekeListTitle)
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing){
                    Button(action: {
                        createCheckItemView.toggle()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
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
        }
        .task {
            await viewModel.getCheckItems()
        }
    }
}

//チェック項目作成ビュー
struct CreateCheckItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel = CheckItemViewModel(repository: CheckItemRepotitory())

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("リスト名")) {
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
                    }
                    .disabled(viewModel.isButtonEnable)
                }
            }
        }
    }
}

//チェック項目編集ビュー
struct EditCheckItemView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel = CheckItemViewModel(repository: CheckItemRepotitory())


    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("項目名")) {
                    TextField("持ち物チェック対象を入力", text: $viewModel.inputItemName)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                Button() {
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
