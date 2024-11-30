import SwiftUI

struct ItemChecklistView: View {
    @StateObject var viewModel = CheckItemViewModel()
    var body: some View {

        NavigationStack(){
            HStack {
                VStack{
                    List {
                        ForEach($viewModel.checkItemList) { $item in
                            if item.id == viewModel.editItemId {
                                TextField("値を入力してください",text: Binding(
                                    get: { item.itemName },
                                    set: { viewModel.editCheckItem(id: item.id, itemName: $0) }
                                ))
                                .listRowBackground(Color.gray)
                            } else {
                                HStack {
                                    Text(item.itemName)
                                    Toggle("",isOn: $item.checked)
                                }
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack {
                                Text("タイトル")
                                    .font(.headline)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing){
                            Button(action: {
                                viewModel.createCheckItem()
                            })
                            {
                                Image(systemName: "plus")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .onTapGesture {
                    viewModel.editFinish()
                }
            }
        }
    }

}
