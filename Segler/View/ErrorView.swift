//
//  Error.swift
//  Segler
//
//  Created by Maximilian Gravemeyer on 05.07.20.
//  Copyright © 2020 Maximilian Gravemeyer. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    
    @ObservedObject var userVM : UserViewModel
    @ObservedObject var settingsVM : SettingsViewModel
    @ObservedObject var mediaVM : MediaViewModel
    @ObservedObject var orderVM : OrderViewModel
    @ObservedObject var remarksVM : RemarksViewModel
    
    var body: some View {
        VStack {
            Image("Error").resizable().frame(width: 200, height: 200)
            Text("Konnte keine Verbindung zum Server herstellen.").fontWeight(.bold)
            Button(action: {
                self.settingsVM.ip = ""
                self.settingsVM.serverPassword = ""
                self.settingsVM.serverUsername = ""
                self.settingsVM.hasSettedUp = false
            }) {
                Text("Zurück")
            }
        }.offset(y: -50).onAppear {
            //1-3 stellig
        }
    }
}
