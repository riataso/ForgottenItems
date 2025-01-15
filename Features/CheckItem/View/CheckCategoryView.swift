import SwiftUI

struct CheckCategoryView: View {
    @StateObject var viewModel = CheckListViewModel(repository: CheckItemRepository())
    @State var createCheckCategoryView: Bool = false
    @State private var showingAlert = false
    @State var editCheckListView: Bool = false
    let alertTitle: String = "警告"

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.checkList) { checkItem in
                    NavigationLink(destination: ItemChecklistView(checkList: checkItem)) {
                        Text(checkItem.title)
                    }
                    .contextMenu {
                        Button {
                            viewModel.editCheckList = checkItem
                            viewModel.listTitle = checkItem.title
                            viewModel.splitDateTime(editDate: checkItem.date)
                            editCheckListView.toggle()
                        } label: {
                            Text("名前を編集")
                        }

                        Button(role: .destructive) {
                            viewModel.editCheckList = checkItem
                            self.showingAlert = true
                        } label: {
                            Text("削除")
                        }
                    }
                }
            }
            .alert(
                alertTitle,
                isPresented: $showingAlert
            ) {
                Button(role: .cancel) {
                    
                } label: {
                    Text("キャンセル")
                }
                Button(role: .destructive) {
                    Task {
                        await viewModel.deleteCheckList()
                    }
                } label: {
                    Text("削除")
                }
            } message: {
                Text("削除されると元に戻すことはできませんがよろしいですか？")
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("持ち物チェックリスト")
                        .font(.headline)
                }
                // リスト追加用フォルダアイコン
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        createCheckCategoryView.toggle()
                    }) {
                        Image(systemName: "folder.badge.plus")
                            .tint(Color("AppPrimaryColor"))
                    }
                }
            }
            .sheet(isPresented: $createCheckCategoryView) {
                CreateListView(viewModel: viewModel)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $editCheckListView) {
                EditCheckListView(viewModel: viewModel)
                    .presentationDragIndicator(.visible)
            }
            .task {
                await viewModel.getCheckList()
            }
        }
    }
}

// リスト作成ビュー
struct CreateListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CheckListViewModel


    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("リスト名")) {
                    TextField("リスト名を入力", text: $viewModel.listTitle)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                //日付追加用カレンダー遷移リスト画面
                Section(header: Text("日付")) {
                    NavigationLink(destination: DatePickerView(selectedDate: $viewModel.selectedDate)) {
                        HStack {
                            Text("日付を選択")
                            Spacer()
                            Text(viewModel.selectedDate, style: .date)
                                .foregroundColor(.gray)
                        }
                    }
                }
                //時間追加用ホイール遷移リスト画面
                Section(header: Text("時間")) {
                    NavigationLink(destination: TimePickerView(selectedTime: $viewModel.selectedTime)) {
                        HStack {
                            Text("時間を選択")
                            Spacer()
                            Text(viewModel.selectedTime, style: .time)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("新しいリストを作成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.clearInputTitle()
                        dismiss()
                    } label: {
                        Text("キャンセル")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.createCheckItemList()
                            dismiss()
                        }
                    } label: {
                        Text("追加")
                    }
                    .disabled(viewModel.isButtonEnable)
                }
            }
        }
        .tint(Color("PrimaryColor"))
    }
}

// 日付ピッカー画面
struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            DatePicker("日付を設定", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
        }
        .datePickerStyle(.graphical)
        .navigationTitle("日付を設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 時間ピッカー画面
struct TimePickerView: View {
    @Binding var selectedTime: Date
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            DatePicker("時間を設定", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
        }
        .navigationTitle("時間を設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// リスト名編集ビュー
struct EditCheckListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CheckListViewModel

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("リスト名")) {
                    TextField("リスト名を入力", text: $viewModel.listTitle)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                //日付追加用カレンダー遷移リスト画面
                Section(header: Text("日付")) {
                    NavigationLink(destination: DatePickerView(selectedDate: $viewModel.selectedDate)) {
                        HStack {
                            Text("日付を選択")
                            Spacer()
                            Text(viewModel.selectedDate, style: .date)
                                .foregroundColor(.gray)
                        }
                    }
                }
                //時間追加用ホイール遷移リスト画面
                Section(header: Text("時間")) {
                    NavigationLink(destination: TimePickerView(selectedTime: $viewModel.selectedTime)) {
                        HStack {
                            Text("時間を選択")
                            Spacer()
                            Text(viewModel.selectedTime, style: .time)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("リストを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.clearInputTitle()
                        dismiss()
                    } label: {
                        Text("キャンセル")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.editCheckList()
                            dismiss()
                        }
                    } label: {
                        Text("保存")
                    }
                    .disabled(viewModel.isEditButtonDisabled)
                }
            }
        }
    }
}
