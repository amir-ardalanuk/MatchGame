//
//  CardCore.swift
//  MatchGame
//
//  Created by Amir on 12/26/21.
//

import Foundation
import ComposableArchitecture

struct Card:  Equatable, Identifiable {
    let id: String
    let content: String
    var isFlipUp: Bool
    var isMatch: Bool
}

enum CardAction {
    case isTap
}

struct CardEnviroment { }

var cardReducer = Reducer<Card, CardAction, CardEnviroment> { state, action, env in
    switch action {
        case .isTap:
        if !state.isMatch {
            if state.isFlipUp == false {
                state.isFlipUp = true
            }
        }
        return .none
    }
    
}
