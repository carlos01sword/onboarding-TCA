import ComposableArchitecture
import SwiftUI

@Reducer
struct DetailReducer {
    @ObservableState
    struct State: Equatable {
        var cell: BreedCellReducer.State
    }
    
    enum Action: Equatable {
        case cell(BreedCellReducer.Action)
    }
        
    var body: some Reducer<State,Action>{
        Scope(state: \.cell, action: \.cell) {
            BreedCellReducer()
        }
    }
}
