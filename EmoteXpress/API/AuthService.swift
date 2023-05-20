//
//  AuthService.swift
//  EmoteXpress
//
//  Created by Eco Dev System on 19/12/2022.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import UIKit

struct RegistrationCredentials {
    let email: String
    let fullname: String
    let username: String
    let password: String
    let profileImage: UIImage
}

struct AuthService {
    static let shared = AuthService()
    
    func logUserIn(withEmail email: String, password: String, completion: ((AuthDataResult?, (any Error)?) -> Void)?) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error {
//                print("DEBUG: Failed to log in with error \(error.localizedDescription)")
//                return
//            }
//
////            self.dismiss(animated: true)
//
//        }
    }
    
    func createUser(credentials: RegistrationCredentials, completion: ((Error?) -> Void)?) {
        guard let imageData = credentials.profileImage.jpegData(compressionQuality: 0.3) else { return }
        
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/profile_images/\(filename)")
        
        ref.putData(imageData, metadata: nil) {meta, error in
            if let error = error {
                completion!(error)
                return
            }
            
            ref.downloadURL { url, error in
                guard let profileImageUrl = url?.absoluteString else { return }
                
                Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
                    if let error = error {
                        completion!(error)
                        return
                    }
                    
                    guard let uid = result?.user.uid else { return }
                    
                    let data = [
                        "email": credentials.email,
                        "fullname": credentials.fullname,
                        "profileImageUrl": profileImageUrl,
                        "uid": uid,
                        "username": credentials.username
                    ] as [String: Any]
                    
                    
                    Firestore.firestore().collection("users").document(uid).setData(data, completion: completion)
//                    Firestore.firestore().collection("users").document(uid).setData(data) { error in
//                        if let error = error {
//                            print("DEBUG: Failed to upload user data with error \(error.localizedDescription)")
//                            return
//                        }
////                        self.dismiss(animated: true)
//
//                    }
                    
                }
            }
            
        }
    }
}
