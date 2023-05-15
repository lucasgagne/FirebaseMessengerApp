//
//  MainMessagesView.swift
//  RSA messenger 2
//
//  Created by lucas gagne on 5/8/23.
//

import SwiftUI
import SDWebImageSwiftUI



class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser : ChatUser?
    @Published var userLoggedOut = false

    
    init() {
        DispatchQueue.main.async {
            self.userLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil

        }
        fetchCurrentUser()
    }
    
    func fetchCurrentUser() {
        errorMessage = "fetching current user"
        guard let uid =
        FirebaseManager.shared.auth
            .currentUser?.uid else {
            self.errorMessage = "could not fetch firebase ID"
            return
            
        }
//        self.errorMessage = "\(uid)"
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).getDocument { snapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch curr user: \(error)"
                    print("failed to fetch user: ", error)
                    return
                }
                
                guard let data = snapshot?.data() else {return}
//                print(data)
//                self.errorMessage = "\(data.description)"'
                self.chatUser = .init(data: data)
                
//                let uid = data["uid"] as? String ?? ""
//                let email = data["email"] as? String ?? ""
//                let profileImage = data["profileimage"] as? String ?? ""
//
//                self.chatUser = ChatUser(uid: uid, email: email, profileImageURL: profileImage)
//                self.errorMessage = chatUser.profileImageURL
            }
        

    }
    
    
    func handleSignOut() {
        
        userLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
    }
    
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var emailString = ""
    @State var trimmedString = ""
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    private var customNavBar: some View {
        HStack {
            WebImage(url: URL(string: vm.chatUser?.profileImage ?? "")).resizable().scaledToFill().frame(width: 50, height: 50).clipped().cornerRadius(50)
            
//            Image(systemName: "person.fill").font(.system(size: 32, weight: .heavy))
            let emailString = "\(vm.chatUser?.email ?? "")"
            let trimmedString = emailString.prefix(while: { character in
                character != "@"
            })
            
            VStack (alignment: .leading, spacing: 4){
//                Text("\(vm.chatUser?.email ?? "")").font(.system(size: 24, weight: .bold))
                Text(trimmedString).font(.system(size: 24, weight: .bold))

                HStack {
                    Circle().foregroundColor(.green).frame(width: 10)
                    Text("online")
                }
                
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label : {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold)).foregroundColor(Color(.label))
            }
            
        }.padding().actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("SIGN OUT"), action: {
//                    print("handle sign out")
                    vm.handleSignOut()
                }), .cancel()
//                        .default(Text("DEFAULT BUTTON")), .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.userLoggedOut, onDismiss: nil) {
            RegisterView(didCompleteLoginProcess: {
                self.vm.userLoggedOut = false
                self.vm.fetchCurrentUser()
            })
        }
    }
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    NavigationLink {
                        Text("destination")
                    } label : {
                        HStack (spacing: 16) {
                            Image(systemName: "person.fill").font(.system(size: 24)).foregroundColor(Color(.label))
                            
                            VStack (alignment: .leading){
                                Text("Username").font(.system(size: 16, weight: .bold))
                                Text("Messeges sent to user").font(.system(size: 14))
                            }
                            Text("22d").font(.system(size: 14, weight: .semibold))
                        }
                    }.foregroundColor(.black)
                    
                    Divider().padding(.vertical, 8)
                }.padding(.horizontal)
                
                
            }.padding(.bottom, 50)
            
            
        }
    }
    
    @State var shouldNavigateToChatLog = false
    var body: some View {
        NavigationView {
            VStack {
                //custum nav bar
//                Text("current user: \(vm.chatUser?.uid ?? "")")
                customNavBar
                
                messagesView
                
//                NavigationLink("", isActive: $shouldNavigateToChatLog) {
//                    Text("Chat log")
//                }
                
                
            }.overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            
            
//            .navigationTitle("main messages view")
        }
    }
    @State var showNewMessageScreen = false
    private var newMessageButton: some View {
        Button {
            showNewMessageScreen.toggle()
        } label : {
            HStack {
                Spacer()
                Text("+ new message")
                Spacer()
            }.foregroundColor(.white).padding(.vertical).background(Color.blue).cornerRadius(32).padding(.horizontal).shadow(radius: 15)
            
        }
        .fullScreenCover(isPresented: $showNewMessageScreen) {
            newMessageView(didSelectUser: { user in
                print(user.email)
                self.shouldNavigateToChatLog.toggle()
                self.chatUser = user
                
            })
        }
    }
    @State var chatUser: ChatUser?
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}


//Left off Video 06, 0:00
