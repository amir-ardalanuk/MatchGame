//
//  MatchGameApp.swift
//  MatchGame
//
//  Created by Amir on 12/21/21.
//

import SwiftUI
import ComposableArchitecture

@main
struct MatchGameApp: App {
    let store: Store<GameSetting, GameSettingAction> = stubStore
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                WithViewStore(store) { viewStore in
                    StartView(store: stubStore)
                        .navigationBarTitleDisplayMode(.inline)
                }
            }.accentColor(.red)
        }
    }
}
