//
//  RegistrationViewModel.swift
//  FireChat
//
//  Created by Eco Dev System on 16/12/2022.
//

import Foundation

struct RegistrationViewModel: AuthenticationProtocal {
    var email: String?
    var fullname: String?
    var username: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && fullname?.isEmpty == false && username?.isEmpty == false && password?.isEmpty == false
    }
}
