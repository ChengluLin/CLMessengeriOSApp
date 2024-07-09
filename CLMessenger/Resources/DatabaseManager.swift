//
//  DatabasseManager.swift
//  CLMessenger
//
//  Created by ChengLu on 2024/7/8.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let  shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
//    public func test() {
//        
//        database.child("foo").setValue(["something": true])
//    }
    
    public func insertUser(with user: ChatAppUser) {
        database.child(user.emailAddress).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
    
    
    
}


struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
//    let profilePictureUrl: String
}
