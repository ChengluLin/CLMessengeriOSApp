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
    
}

//MARK: - Account Management

extension DatabaseManager {
    /// 判斷使用者是否存在
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            print("snapshot：", snapshot.key)
            guard snapshot.value != nil else {
                completion(false)// 已存在使用者
                return
            }
            
            completion(true) // 不存在使用者
        }
        
    }
    
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
        ])
    }
}


struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    //    let profilePictureUrl: String
}
