//
//  LoginViewModel.swift
//  FireChat
//
//  Created by Eco Dev System on 15/12/2022.
//

import Foundation

protocol AuthenticationProtocal {
    var formIsValid: Bool { get }
}

struct LoginViewModel: AuthenticationProtocal {
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        return email?.isEmpty == false && password?.isEmpty == false
    }
}
