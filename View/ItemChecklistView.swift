import SwiftUI

struct ItemChecklistView: View {
    @State var isChecked: Bool = false
    @State var flag = false
    @StateObject var viewModel = CheckItemViewModel()
    var body: some View {

        NavigationStack(){
            HStack {
                VStack{
                    List {
                        ForEach(viewModel.checkItemList) { item in
                            if item.id == viewModel.editItemId {
                                TextField("値を入力してください",text: Binding(
                                    get: { item.itemName },
                                    set: { viewModel.editCheckItem(id: item.id, itemName: $0) }
                                ))
                                .listRowBackground(Color.gray)
                            } else {
                                Text(item.itemName)
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
