//
//  GameBoardView.swift
//  MatchGame
//
//  Created by Amir on 12/21/21.
//

import SwiftUI
import ComposableArchitecture

struct GameBoardView: View {
    let store: Store<GameBoardState, GameBoardAction>
    
    var body: some View {
        VStack {
            WithViewStore(store) { viewStore in
                HStack {
                    Text("Remain time: \(viewStore.remainTime)")
                    Spacer()
                    Text("Point: \(viewStore.points)")
                }
                .foregroundColor(.red)
                .padding(.horizontal, 8)
                .alert(isPresented: Binding.constant(viewStore.summeryState != nil)) {
                    Alert(
                        title: Text(viewStore.summeryState.flatMap { $0.isWin ? "You Win" : "You Lose" } ?? ""),
                        message: Text("Remain time: \(viewStore.summeryState?.remainTime ?? 0)\n Total Point: \(viewStore.summeryState?.finalPoint ?? 0)"),
                        primaryButton: .cancel({
                            viewStore.send(.dismissGame)
                        }),
                        secondaryButton: .default(Text("Retry"), action: {
                            viewStore.send(.resetGame)
                        }))
                }
            }
            
            GeometryReader { proxy in
                LazyVGrid(columns: [.init(.adaptive(minimum: proxy.size.width / 4, maximum: proxy.size.width / 4), spacing: 0, alignment: .center)]) {
                    ForEachStore(store.scope(state: \.cards, action: GameBoardAction.card(id: action:)), content: CardView.init(store: ))
                        .frame(width: proxy.size.width / 4, height: (proxy.size.height / 4), alignment: .center)
                }
                .frame(width: proxy.size.width, height: proxy.size.height - 10, alignment: .top)
            }
            
            Spacer(minLength: 20)
        }
        .navigationBarItems(trailing: WithViewStore(store) { viewStore in
            Button {
                viewStore.send(.resetGame)
            } label: {
                Image(systemName: "gobackward")
            }
        } ).foregroundColor(.red)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarTitle(Text("Match Item"))
        .padding(8.0)
    }
}

struct GameBoardView_Previews: PreviewProvider {
    static var previews: some View {
        GameBoardView(store: Store<GameBoardState, GameBoardAction>(
            initialState: GameBoardState.init(cards: [
                Card(id: UUID().uuidString, content: "A", isFlipUp: false, isMatch: false),
                Card(id: UUID().uuidString, content: "B", isFlipUp: false, isMatch: false),
                Card(id: UUID().uuidString, content: "C", isFlipUp: false, isMatch: false),
                Card(id: UUID().uuidString, content: "A", isFlipUp: false, isMatch: false),
                Card(id: UUID().uuidString, content: "B", isFlipUp: false, isMatch: false),
                Card(id: UUID().uuidString, content: "C", isFlipUp: false, isMatch: false)
            ], remainTime: 30, isGameStart: false, points: 0),
            reducer: gameBoardReducer,
            environment: GameBoardEnviroment())
        )
    }
}
