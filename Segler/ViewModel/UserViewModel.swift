//
//  UserViewModel.swift
//  Segler
//
//  Created by Maximilian Gravemeyer on 02.09.20.
//  Copyright © 2020 Maximilian Gravemeyer. All rights reserved.
//

import Foundation

class UserViewModel: ObservableObject {
    @Published var username = String()
    @Published var password = String()
    @Published var loggedIn = false
}
