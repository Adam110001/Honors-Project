//
//  SupportingViewCode.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 21/03/2021.
//

import Foundation
import UIKit

extension UIView {
    
    public var bottom: CGFloat {
        return self.frame.size.height + self.frame.origin.y
    }
}

extension Notification.Name {
    
    // Notificaiton  when user logs in
    static let didLogInNotification = Notification.Name("didLogInNotification")
}
