//
//  MessageViewModel.swift
//  EmoteXpress
//
//  Created by Eco Dev System on 03/01/2023.
//

import UIKit

struct MessageViewModel {
    
    private let message: Message
    
    var messageBackgroundColor: UIColor {
        return message.isFromCurrentUser ? UIColor(named: "PurpleColor")!.withAlphaComponent(0.3) : UIColor(named: "PurpleColor")!
    }
    
    var messageTextColor: UIColor {
        return message.isFromCurrentUser ? UIColor(named: "PurpleColor")! : .white
    }
    
    var rightAnchorActive: Bool {
        return message.isFromCurrentUser
    }
    
    var leftAnchorActive: Bool {
        return !message.isFromCurrentUser
    }
    
    var shouldHideProfileImage: Bool {
        return message.isFromCurrentUser
    }
    
    var profileImageUrl: URL? {
        guard let user = message.user else { return nil }
        return URL(string: user.profileImageUrl)
    }
    
    init(message: Message) {
        self.message = message
    }
}
