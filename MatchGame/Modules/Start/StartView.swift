//
//  StartView.swift
//  MatchGame
//
//  Created by Amir on 12/22/21.
//

import SwiftUI
import ComposableArchitecture

struct StartView: View {
    var store: Store<GameSetting, GameSettingAction>
    
    var body: some View {
        VStack(spacing: 16) {
            Text("MATCH GAME")
                .font(.headline)
            
            WithViewStore(store) { viewStore in
                VStack(spacing: 8) {
                    Text("Timer: ")
                    HStack {
                        ForEach(viewStore.timerOptions) { option in
                            let isActive = viewStore.selectedTimerOption == option
                            Button {
                                viewStore.send(.changeTimerOption(option))
                            } label: {
                                Text(option.title)
                                    .padding()
                                    .foregroundColor(isActive ? .red : .white)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(isActive ? .white : .clear)
                                    )
                            }
                        }
                    }
                }
                
                VStack(spacing: 8) {
                    Text("Charecters: ")
                    HStack {
                        ForEach(viewStore.charecterOptions) { option in
                            let isActive = viewStore.selectedCharecterOption == option
                            Button {
                                viewStore.send(.changeCharecterOption(option))
                            } label: {
                                Text(option.category.items(range: 1).first ?? "")
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(isActive ? .white : .clear)
                                    )
                                    
                                    
                            }
                            .padding()
                        }
                    }
                }
                
                
                NavigationLink(
                    destination: IfLetStore(store.scope(state: \.gameState, action: GameSettingAction.gameBoardAction),
                                            then: GameBoardView.init(store: )),
                    isActive: viewStore.binding(
                        get: { $0.gameState != nil },
                        send: { $0 ? .startGame : .dismissGame}
                    ),
                    label: {
                        Text("Start")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50, alignment: .center)
                            .background(RoundedRectangle(cornerRadius: 16)
                                            .foregroundColor(.white)
                            )
                    }
                )
            }
        }
        .padding()
        .foregroundColor(.white)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(.red)
        )
        .padding()
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView(
            store: stubStore
        )
    }
}
