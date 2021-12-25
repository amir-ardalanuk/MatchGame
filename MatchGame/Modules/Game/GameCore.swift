//
//  GameCore.swift
//  MatchGame
//
//  Created by Amir on 12/26/21.
//

import Foundation
import ComposableArchitecture

struct SummeryState: Equatable {
    var remainTime: Int
    var finalPoint: Int
    var isWin: Bool
}

struct GameBoardState: Equatable {
    var cards: IdentifiedArrayOf<Card> = []
    var firstSelectedCard: Card?
    var secondSelectedCard: Card?
    var remainTime: Int
    var isGameStart: Bool
    var points: Int
    var summeryState: SummeryState?
}

enum GameBoardAction: Equatable {
    case card(id: Card.ID, action: CardAction)
    case checkMatchItem
    
    case timerTick
    case startTimer
    
    case endGame
    case dismissSummery
    case dismissGame
    case resetGame
}

struct GameBoardEnviroment {}

struct TimerId: Hashable {}

fileprivate func checkMatchItems(state: inout GameBoardState) -> Effect<GameBoardAction, Never> {
    var cards = state.cards
    guard let firstCard = state.firstSelectedCard, let secondCard = state.secondSelectedCard else {
        return .none
    }
    let isSame = firstCard.content == secondCard.content
    cards[id: firstCard.id]?.isMatch = isSame
    cards[id: firstCard.id]?.isFlipUp = isSame
    
    cards[id: secondCard.id]?.isMatch = isSame
    cards[id: secondCard.id]?.isFlipUp = isSame
    
    let newPoint = state.points + (isSame ? 5 : -2)
    state.points = newPoint > 0 ? newPoint : 0
    state.firstSelectedCard = nil
    state.secondSelectedCard = nil
    state.cards = cards
    
    if cards.allSatisfy({ $0.isMatch }) {
        return Effect(value: .endGame)
    } else {
        return .none
    }
}

fileprivate func didSelectOnCard(withId id: Card.ID, state: inout GameBoardState) -> Effect<GameBoardAction, Never> {
    var cards = state.cards
    guard state.firstSelectedCard == nil || state.secondSelectedCard == nil else {
        cards[id: id]?.isFlipUp = false
        state.cards = cards
        return .none
    }
    
    guard let card = state.cards[id: id] else { return .none }
    if let selectedCard = state.firstSelectedCard {
        if selectedCard != card {
            state.secondSelectedCard = card
            return Effect(value: GameBoardAction.checkMatchItem)
                .delay(for: 1, scheduler: DispatchQueue.main)
                .eraseToEffect()
        }
    } else {
        state.firstSelectedCard = card
        if !state.isGameStart {
            state.isGameStart = true
            return Effect(value: .startTimer)
        }
    }
    return .none
}

var gameBoardReducer = Reducer<GameBoardState, GameBoardAction, GameBoardEnviroment>.combine(
    cardReducer.forEach(
        state: \.cards,
        action: /GameBoardAction.card(id: action:),
        environment: { _ in
            CardEnviroment()
        }
    ),
    Reducer<GameBoardState, GameBoardAction, GameBoardEnviroment> { state, action, env in
        switch action {
        case let .card(id, _):
            return didSelectOnCard(withId: id, state: &state)
        case .checkMatchItem:
            return checkMatchItems(state: &state)
        case .timerTick:
            if state.remainTime > 0 {
                state.remainTime = state.remainTime - 1
                return .none
            } else {
                return Effect(value: .endGame)
            }
        case .startTimer:
           return Effect.timer(id: TimerId(), every: 1, tolerance: .zero, on: DispatchQueue.main)
                .map { _ in GameBoardAction.timerTick }
        case .endGame:
            let summery = SummeryState(remainTime: state.remainTime, finalPoint: state.points, isWin: state.cards.allSatisfy({ $0.isMatch }))
            state.summeryState = summery
            return .cancel(id: TimerId())
            
        case .dismissSummery:
            return Effect(value: .dismissGame)
        case .resetGame:
            return .cancel(id: TimerId())
        case .dismissGame:
            return .cancel(id: TimerId())
        }
    }
)
