//
//  DatabaseManager.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 22/03/2021.
//  Some code has been used from https://www.youtube.com/watch?v=Mroju8T7Gdo&list=PL5PR3UyfTWvdlk-Qi-dPtJmjTj-2YIMMf
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let databaseManager = DatabaseManager()
    
    private let database = Database.database().reference()
    
    // Substitutes illegal characters with valid once
    static func preprocessedEmail(emailAddress: String) -> String {
        var preprocessedEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        
        preprocessedEmail = preprocessedEmail.replacingOccurrences(of: "@", with: "-")
        
        return preprocessedEmail
    }
}

// MARK: - Account Managment

extension DatabaseManager {
    
    // Checks if user exists
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void )) {
        
        var preprocessedEmail = email.replacingOccurrences(of: ".", with: "-")
        preprocessedEmail = preprocessedEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(preprocessedEmail).observeSingleEvent(of: .value, with: {
            snapshot in
            
            guard  snapshot.value as? String != nil else {
                completion(false )
                return
            }
            
            completion(true)
        })
    }
    
    // Insert new user into the database
    public func insertUser(with user: UserDetails, completion: @escaping (Bool) -> Void) {
        database.child(user.preprocessedEmail).setValue(["firstName": user.firstName, "lastName": user.lastName], withCompletionBlock: {
            error, _ in
            
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            
            completion(true)
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
        
        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }
}

extension DatabaseManager {
    
    // Return dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
    
}

// MARK - Unique User Characteristics

struct UserDetails {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    // Substitutes illegal characters with valid once
    var preprocessedEmail: String {
        var preprocessedEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        
        preprocessedEmail = preprocessedEmail.replacingOccurrences(of: "@", with: "-")
        
        return preprocessedEmail
    }
    
    var profilePictureFileName: String {
        return "\(preprocessedEmail)_profile_picture.png"
    }
}
