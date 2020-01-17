import SwiftUI
import Combine

private class Thunk: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()

    var dataSource: NumericArrayPublisher? = nil
    @Published var arrayValue: [Double] = []

    init(dataSource: NumericArrayPublisher?) {
        guard let dataSource = dataSource else { return }

        self.dataSource = dataSource

        dataSource
        .receive(on: RunLoop.main)
        .assign(to: \.arrayValue, on: self)
        .store(in: &subscriptions)
    }
}

struct StripChartView: View {
    @ObservedObject fileprivate var thunk = Thunk(dataSource: nil)
    let dataSource: NumericArrayPublisher

    init(dataSource: NumericArrayPublisher) {
        self.dataSource = dataSource
        thunk = Thunk(dataSource: dataSource)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle().fill(Color.red)
                Rectangle().fill(Color.orange)
                Rectangle().fill(Color.yellow)
                Rectangle().fill(Color.green)
                Rectangle().fill(Color.blue)
            }
            LineChart(values: thunk.arrayValue)
        }
    }
}

struct LineChart: View {

    let values: [Double]
    
    init(values: [Double]) {
        self.values = values
    }

    var body: some View {
        Path { path in
            guard let first = values.first else { return }

            var y: CGFloat = CGFloat(first)
            path.move(to: CGPoint(x: CGFloat(0), y: y * 2))

            for i in 1..<values.count {
                y = CGFloat(values[i])
                path.addLine(to: CGPoint(x: CGFloat(2 + i * 5), y: y * 2))
            }
        }
        .stroke(Color.black, lineWidth: 3)
    }
}
