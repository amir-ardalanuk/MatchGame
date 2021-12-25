//
//  StartCore.swift
//  MatchGame
//
//  Created by Amir on 12/26/21.
//

import Foundation
import ComposableArchitecture

struct TimerOption: Hashable, Identifiable {
    var id: TimeInterval { duration }
    var duration: TimeInterval
    var title: String {
        "\(duration) s"
    }
}

struct CharecterOption: Hashable, Identifiable {
    var id: EmojiCategory { category }
    var category: EmojiCategory
}

struct GameSetting: Equatable {
    let timerOptions: IdentifiedArrayOf<TimerOption>
    let charecterOptions: IdentifiedArrayOf<CharecterOption>
    var selectedTimerOption: TimerOption
    var selectedCharecterOption: CharecterOption
    var gameState: GameBoardState?
}

enum GameSettingAction {
    case changeTimerOption(TimerOption)
    case startGame
    case dismissGame
    case clearGameState
    case gameBoardAction(action: GameBoardAction)
    case changeCharecterOption(CharecterOption)
}

struct GameSettingEnviroment {}

fileprivate var charecterOptions = IdentifiedArrayOf(uniqueElements: EmojiCategory.allCases.map { CharecterOption(category: $0) })
fileprivate var timerOptions = IdentifiedArrayOf(uniqueElements:[TimerOption(duration: 30), TimerOption(duration: 60), TimerOption(duration: 90)])

fileprivate func makeNewBoard(withTime time: Int, category: EmojiCategory) -> GameBoardState {
    let cards: [Card] = category.items()
        .shuffled()
        .prefix(8)
        .flatMap {
            [Card(id: UUID().uuidString, content: $0, isFlipUp: false, isMatch: false),
             Card(id: UUID().uuidString, content: $0, isFlipUp: false, isMatch: false)
            ]
        }.shuffled()
    return GameBoardState(
        cards: IdentifiedArrayOf(uniqueElements: cards),
        remainTime: time, isGameStart: false, points: 0)
}

var stubStore: Store<GameSetting, GameSettingAction> = .init(
    initialState: .init(
        timerOptions: timerOptions,
        charecterOptions: charecterOptions,
        selectedTimerOption: timerOptions.first!,
        selectedCharecterOption: charecterOptions.first!),
    reducer: gameSettingReducer,
    environment: GameSettingEnviroment()
)

var gameSettingReducer = Reducer<GameSetting, GameSettingAction, GameSettingEnviroment>.combine(
    .init({ state, action, env in
        switch action {
        case let .changeCharecterOption(option):
            state.selectedCharecterOption = option
            return .none
        case let .changeTimerOption(option):
            state.selectedTimerOption = option
            return .none
        case .startGame, .gameBoardAction(.resetGame):
            state.gameState = makeNewBoard(
                withTime: Int(state.selectedTimerOption.duration),
                category: state.selectedCharecterOption.category
            )
            return .none
        case .dismissGame, .gameBoardAction(.dismissGame):
            return .cancel(id: TimerId())
                .merge(with: Effect(value: GameSettingAction.clearGameState))
                .eraseToEffect()
        case  .gameBoardAction:
            return .none
        case .clearGameState:
            state.gameState = nil
            return .none
        }
    }),
    gameBoardReducer
        .optional()
        .pullback(state: \.gameState,
                  action: /GameSettingAction.gameBoardAction(action: ),
                  environment: { _ in
                      GameBoardEnviroment()
                  })
)
