//
//  newMessageView.swift
//  RSA messenger 2
//
//  Created by lucas gagne on 5/13/23.
//

import SwiftUI
import SDWebImageSwiftUI

class newMessageViewModel: ObservableObject {
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentsSnapshot, error in
            if let error = error {
                self.errorMessage = "failed to fetch users: \(error)"
                print(self.errorMessage)
                return
            }
            documentsSnapshot?.documents.forEach({snapshot in
                let data = snapshot.data()
                self.users.append(.init(data: data))
            })
//            self.errorMessage = "got the users great success"
        }
    }
}

struct newMessageView: View {
    let didSelectUser: (ChatUser) -> ()
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = newMessageViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                ForEach(vm.users) { user in
                    Button {
                        didSelectUser(user)
                    } label : {
                        NavigationLink {
                            ChatLogView(chatUser: user)
                        } label : {
                            HStack (spacing: 16){

                                WebImage(url: URL(string: user.profileImage)).resizable().frame(width: 50, height: 50).scaledToFill().clipped().cornerRadius(50)
                                Text(user.email).foregroundColor(Color(.label))
                                Spacer()
                                
                            }.padding(.horizontal)
                        }
                        
                       
                    }
                    Divider().padding(.vertical, 8)
                    
                    
                    
                   
                    
                }
            }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement:.navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label : {
                            Text("Cancel")
                        }
                    }
                }
        }
    }
}

struct ChatLogView: View {
    
    let chatUser: ChatUser?
    
    var body: some View {
        ScrollView {
            ForEach(0..<5) { num in
                Text("\(num)")
            }
        }.navigationTitle(chatUser?.email ?? "")
    }
}


struct newMessageView_Previews: PreviewProvider {
    static var previews: some View {
//        newMessageView()
        MainMessagesView()
    }
}
