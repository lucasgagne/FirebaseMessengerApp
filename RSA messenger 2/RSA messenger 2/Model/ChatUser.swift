//
//  ChatUser.swift
//  RSA messenger 2
//
//  Created by lucas gagne on 5/9/23.
//

import Foundation

struct ChatUser: Identifiable {
    var id: String {uid}
    let uid, email, profileImage: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImage = data["profileimage"] as? String ?? ""
    }
}
 
