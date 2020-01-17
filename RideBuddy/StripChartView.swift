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
    let heartZones: HeartZones
    let zonePercentages: [CGFloat]

    init(dataSource: NumericArrayPublisher, heartZones: HeartZones) {
        self.dataSource = dataSource
        self.heartZones = heartZones
        zonePercentages = heartZones.zonePercentages().map { CGFloat($0) }
        thunk = Thunk(dataSource: dataSource)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
            Text("frame \(geometry.size.width) \(geometry.size.height)")
            ZStack {
                // will eventually need to make the height proportional to the
                // height of the zone.
                // c.f. https://github.com/markd2/RideBuddy/raw/master/design-docs/assets/2x-graph.png
                VStack(spacing: 0) {
                    ZoneSwatch(zoneLabel: "Z5", color: .red, boundary: 150)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[4])
                    ZoneSwatch(zoneLabel: "Z4", color: .orange, boundary: 138)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[3])
                    ZoneSwatch(zoneLabel: "Z3", color: .yellow, boundary: 125)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[2])
                    ZoneSwatch(zoneLabel: "Z2", color: .green, boundary: 108)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[1])
                    ZoneSwatch(zoneLabel: "Z1", color: .blue, boundary: 90)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[0])
                }
                LineChart(values: self.thunk.arrayValue, heartZones: self.heartZones)
            }
            }
        }
    }
}

struct ZoneSwatch: View {
    let zoneLabel: String
    let color: Color
    let boundary: Int

    var body: some View {
        ZStack {
            Rectangle().fill(color)
            HStack {
                Text("\(boundary)").padding(.leading)
                Spacer()
                Text(zoneLabel).padding(.trailing)
            }.foregroundColor(.white)
        }
    }
}

struct LineChart: View {

    let values: [Double]
    let heartZones: HeartZones
    
    init(values: [Double], heartZones: HeartZones) {
        self.values = values
        self.heartZones = heartZones
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
