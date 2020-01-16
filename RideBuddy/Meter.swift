import Foundation
import SwiftUI
import Combine

typealias DataSource = AnyPublisher<String, Never>

struct MeterSource {
    let name: String
    let dataSource: DataSource // String/Never publisher
}

private class Thunk: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()

    var meterSource: MeterSource? = nil
    @Published var stringValue: String = "---"

    init(meterSource: MeterSource? ) {
        guard let meterSource = meterSource else {
            return
        }

        self.meterSource = meterSource

        meterSource.dataSource
        .receive(on: RunLoop.main)
        .assign(to: \.stringValue, on: self)
        .store(in: &subscriptions)
    }
    
}

struct MeterView: View {
    @ObservedObject fileprivate var thunk = Thunk(meterSource: nil)

    let meterSource: MeterSource
    
    init(meterSource: MeterSource) {
        self.meterSource = meterSource
        thunk = Thunk(meterSource: meterSource)
    }

    var body: some View {
        VStack {
            Text(thunk.stringValue).font(.largeTitle)
            Text(meterSource.name).font(.callout)
        }.padding()
    }
}

