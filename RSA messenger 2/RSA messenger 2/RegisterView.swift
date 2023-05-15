//
//  ContentView.swift
//  RSA messenger 2
//
//  Created by lucas gagne on 5/5/23.
//

import SwiftUI
import Firebase
//import FirebaseStorage




struct RegisterView: View {
    
    let didCompleteLoginProcess: () -> ()
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var showImagePicker = false
    

    var body: some View {
        NavigationView {
            ScrollView {
                VStack (spacing: 16){
                    Picker(selection: $isLoginMode, label: Text("picker dude")) {
                        Text("login").tag(true)
                        Text("Create Account").tag(false)
                    }.pickerStyle(SegmentedPickerStyle()).padding()
                    
                    if !isLoginMode {
                        Button {
                            showImagePicker.toggle()
                        } label: {
                            
                            VStack {
                                if let image = self.image {
                                    Image(uiImage: image).resizable()
                                        .frame(width: 124, height: 124)
                                        .scaledToFill().cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill").font(.system(size: 64)).padding().foregroundColor(.gray)
                                }
                            }
                            

                        }
                    }
                    
                    
                    
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress).autocapitalization(.none)
                    SecureField("Password", text: $password)
                    
                    Button {
                        handleAction()
                    } label : {
                        Spacer()
                        Text(isLoginMode ? "Login" : "Create account").foregroundColor(.white)
                            .padding(.vertical, 10)
                        Spacer()
                    }.background(Color.blue)
                }.padding()
                
                Text(self.loginStatusMessage).foregroundColor(.red)
                
                

                
            }.navigationTitle(isLoginMode ? "Log in" : "Create account")
                .fullScreenCover(isPresented: $showImagePicker, onDismiss: nil) {
                    Text("test example")
//                    If we want an image picker to select a profile page, link the function below..
                    ImagePicker(image: $image)
                }
        }
        .padding()
    }
    @State var image: UIImage?

    private func handleAction() {
        if isLoginMode {
            loginUser()
        } else {
            createNewAccount()
        }
    }
    
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, error in
            if let error = error {
                print("failed to Login user: ", error)
                self.loginStatusMessage = "Failed to Login user: \(error)"
                return
            }
            print("successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully Logged in user: \(result?.user.uid ?? "")"
            self.didCompleteLoginProcess()

        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, error in
            if let error = error {
                print("failed to create user: ", error)
                self.loginStatusMessage = "Failed to create user: \(error)"
                return
            }
            print("successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
            self.persistImageToStorage()

        }
    }
    
    private func persistImageToStorage() {
        let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else {return}
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return}
        ref.putData(imageData, metadata: nil) {metadata, err in
            if let err = err {
                self.loginStatusMessage = "failed to push image to storage: \(err)"
                return
            }
            ref.downloadURL { url, err in
                if let err = err {
                    self.loginStatusMessage = "Failed to retrieve download URL: \(err)"
                    return
                }
                self.loginStatusMessage = "successfully stored image with url: \(url?.absoluteString ?? "")"
                print(url?.absoluteString)
                
                guard let url = url else {return}
                self.storeUserInformation(profileImage: url)
                
            }
        }
    }
    private func storeUserInformation(profileImage: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
        return
        }
        let userData = ["email": self.email, "uid": uid, "profileimage": profileImage.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }
                print("success")
                self.didCompleteLoginProcess()

            }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(didCompleteLoginProcess: {
            
        })
    }
}
