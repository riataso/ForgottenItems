import SwiftUI

struct CheckCategoryView: View {
    @StateObject var viewModel = CheckListViewModel()
    @State var createCheckCategoryView: Bool = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.checkList) { checkItem in
                    NavigationLink(destination: ItemChecklistView(chekeListTitle: checkItem.title)) {
                        Text(checkItem.title)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                        Text("持ち物チェックリスト")
                            .font(.headline)
                }
                //リスト追加用フォルダアイコン
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
        }
    }
}

struct CreateListView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel = CheckListViewModel()
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("リスト名")) {
                    TextField("リスト名を入力", text: $viewModel.listTitle)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                //日付追加用カレンダー遷移リスト画面
                Section(header: Text("日付")) {
                    NavigationLink(destination: DatePickerView(selectedDate: $selectedDate)) {
                        HStack {
                            Text("日付を選択")
                            Spacer()
                            Text(selectedDate, style: .date)
                                .foregroundColor(.gray)
                        }
                    }
                }
                //時間追加用ホイール遷移リスト画面
                Section(header: Text("時間")) {
                    NavigationLink(destination: TimePickerView(selectedTime: $selectedTime)) {
                        HStack {
                            Text("時間を選択")
                            Spacer()
                            Text(selectedTime, style: .time)
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
                        dismiss()
                    } label: {
                        Text("キャンセル")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.createCheckItemList()
                        dismiss()
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
            DatePicker("日付を選択", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
        }
        .datePickerStyle(.graphical)
        .navigationTitle("日付を選択")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 時間ピッカー画面
struct TimePickerView: View {
    @Binding var selectedTime: Date
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            DatePicker("時間を選択", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
        }
        .navigationTitle("時間を選択")
        .navigationBarTitleDisplayMode(.inline)
    }
}

