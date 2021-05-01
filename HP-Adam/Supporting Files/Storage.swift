//
//  Storage.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 23/03/2021.
//  Some code has been used from https://www.youtube.com/watch?v=Mroju8T7Gdo&list=PL5PR3UyfTWvdlk-Qi-dPtJmjTj-2YIMMf
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let storageManager = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String,Error>) -> Void
    
    /// Upload image to stroage
    public func uploadProfilePicture(with data: Data,  fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {
            metedata, error in
            
            guard error == nil else {
                print("Failed to upload image to databse")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: {
                url, error in
                
                guard let url = url else {
                    print("Failed to get download URL")
                    completion(.failure(StorageErrors.failedToGetValidURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned")
                completion(.success(urlString))
            })
        })
    }
    
    public func uploadAnImageTakenByUser(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("imageTakenByAUser/\(fileName)").putData(data, metadata: nil, completion: {
            metadate, error in
            
            guard error == nil else {
                print("Failed to upload image to databse")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("imageTakenByAUser/\(fileName)").downloadURL(completion: {
                url, error in
                
                guard let url = url else {
                    print("Failed to get download URL")
                    completion(.failure(StorageErrors.failedToGetValidURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned")
                completion(.success(urlString))
            })
        })
    }
    
    public func uploadAnImageTakenByUserReal(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("imageTakenByAUserReal/\(fileName)").putData(data, metadata: nil, completion: {
            metadate, error in
            
            guard error == nil else {
                print("Failed to upload image to databse")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("imageTakenByAUserReal/\(fileName)").downloadURL(completion: {
                url, error in
                
                guard let url = url else {
                    print("Failed to get download URL")
                    completion(.failure(StorageErrors.failedToGetValidURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download url returned")
                completion(.success(urlString))
            })
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetValidURL
    }
    
    public func URLDownloadImage(for path: String, completion: @escaping (Result <URL,Error>) -> Void) {
        
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetValidURL))
                return
            }
            
            completion(.success(url))
        })
    }
}
