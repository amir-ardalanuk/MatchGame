//
//  CardView.swift
//  MatchGame
//
//  Created by Amir on 12/21/21.
//

import SwiftUI
import ComposableArchitecture

struct CardView: View {
    let store: Store<Card, CardAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.red, lineWidth: 2)
                    .frame(minHeight: 20)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(viewStore.isFlipUp ? .clear : .red)
                    )
                    .padding(8)
                
                if viewStore.isFlipUp {
                    Text(viewStore.content)
                        .font(.largeTitle)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if !viewStore.isMatch {
                    viewStore.send(.isTap)
                }
            }
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView.init(
            store: .init(
                initialState: Card.init(id: UUID().uuidString, content: "T",
                                        isFlipUp: false,
                                        isMatch: false),
                reducer: cardReducer,
                environment: CardEnviroment()
            )
        )
    }
}
