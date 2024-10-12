//
//  ProfileViewModel.swift
//  CLMessenger
//
//  Created by ChengLu on 2024/10/10.
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
