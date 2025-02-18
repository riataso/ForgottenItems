import SwiftUI

struct CheckListView: View {
    @State var viewModel = CheckListViewModel(repository: CheckItemRepository())
    @State var createCheckCategoryView: Bool = false
    @State private var showingAlert = false
    @State var editCheckListView: Bool = false
    @State var creditView: Bool = false
    let alertTitle: String = "警告"

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.checkList) { checkItem in
                    NavigationLink(destination: CheckItemView(checkList: checkItem)) {
                        Text(checkItem.title)
                    }
                    .contextMenu {
                        Button {
                            viewModel.editCheckList = checkItem
                            viewModel.listTitle = checkItem.title
                            viewModel.splitDateTime(editDate: checkItem.date)
                            editCheckListView.toggle()
                        } label: {
                            Text("リストを編集")
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
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        creditView.toggle()
                    }) {
                        Image(systemName: "info.circle.fill")
                    }
                }
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
            .sheet(isPresented: $creditView) {
                CreditView()
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
    @State var viewModel: CheckListViewModel

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
    @State var viewModel: CheckListViewModel

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

struct CreditView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List {
                // 開発者情報へのリンク
                NavigationLink(destination: DeveloperDetailView()) {
                    Text("開発者情報")
                }
                // LICENSEへのリンク
                NavigationLink(destination: LicenseDetailView()) {
                    Text("LICENSE")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("キャンセル")
                    }
                }
            }
            .navigationTitle("クレジット情報")
            .navigationBarTitleDisplayMode(.inline) // タイトル表示モードを統一
        }
    }
}

struct DeveloperDetailView: View {
    var body: some View {
        List {
            // 開発者情報のセクション
            Section(header: Text("開発者")) {
                HStack {
                    Text("名前")
                    Spacer()
                    Text("riataso")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("バージョン")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("開発者情報")
        .navigationBarTitleDisplayMode(.inline)
    }
}




struct LicenseDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("ライセンスの詳細情報を以下に記載します。")
                    .padding([.leading, .trailing, .top])

                Text("ライセンス情報:")
                    .font(.headline)
                    .padding(.horizontal)

                // クレジット情報をVStackで見やすく表示
                VStack(alignment: .leading, spacing: 8) {
                    Text("Icons made by")

                    Link("フリーピック", destination: URL(string: "https://www.flaticon.com/ authors/freepik ")!)
                        .foregroundColor(.blue)
                        .underline()

                    Text("from")

                    Link("www.flaticon.com", destination: URL(string: "https://www.flaticon.com/")!)
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding()
            }
        }
        .navigationTitle("ライセンス情報")
        .navigationBarTitleDisplayMode(.inline)
    }
}
