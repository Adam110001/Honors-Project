//
//  ProfileViewModel.swift
//  HP-Adam
//
//  Created by Adam Dovciak on 24/03/2021.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
