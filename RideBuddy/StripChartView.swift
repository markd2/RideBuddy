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
        let redColors = Gradient(colors: [HeartZonesColor.redHigh, HeartZonesColor.redLow])
        let redGradient = LinearGradient(gradient: redColors, startPoint: .top, endPoint: .bottom)

        let orangeColors = Gradient(colors: [HeartZonesColor.orangeHigh, HeartZonesColor.orangeLow])
        let orangeGradient = LinearGradient(gradient: orangeColors, startPoint: .top, endPoint: .bottom)

        let yellowColors = Gradient(colors: [HeartZonesColor.yellowHigh, HeartZonesColor.yellowLow])
        let yellowGradient = LinearGradient(gradient: yellowColors, startPoint: .top, endPoint: .bottom)

        let greenColors = Gradient(colors: [HeartZonesColor.greenHigh, HeartZonesColor.greenLow])
        let greenGradient = LinearGradient(gradient: greenColors, startPoint: .top, endPoint: .bottom)

        let blueColors = Gradient(colors: [HeartZonesColor.blueHigh, HeartZonesColor.blueLow])
        let blueGradient = LinearGradient(gradient: blueColors, startPoint: .top, endPoint: .bottom)

        return GeometryReader { geometry in
            ZStack {
                // will eventually need to make the height proportional to the
                // height of the zone.
                // c.f. https://github.com/markd2/RideBuddy/raw/master/design-docs/assets/2x-graph.png
                VStack(spacing: 0) {
                    ZoneSwatch(zoneLabel: "Z5", color: redGradient, boundary: 150)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[4])
                    ZoneSwatch(zoneLabel: "Z4", color: orangeGradient, boundary: 138)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[3])
                    ZoneSwatch(zoneLabel: "Z3", color: yellowGradient, boundary: 125)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[2])
                    ZoneSwatch(zoneLabel: "Z2", color: greenGradient, boundary: 108)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[1])
                    ZoneSwatch(zoneLabel: "Z1", color: blueGradient, boundary: 90)
                        .frame(width: geometry.size.width,
                            height: geometry.size.height * self.zonePercentages[0])
                }
                LineChart(values: self.thunk.arrayValue, heartZones: self.heartZones)
            }.clipped()
        }
    }
}

struct ZoneSwatch: View {
    let zoneLabel: String
    let color: LinearGradient
    let boundary: Int

    var body: some View {
        ZStack {
            Rectangle().fill(color)
            HStack {
                Text("\(boundary)").bold().padding(.leading)
                Spacer()
                Text(zoneLabel).bold().padding(.trailing)
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

    func transform(heartRate: Double, height: CGFloat, frame: CGRect) -> CGFloat {
        // I have a heart rate.
        // the line chart has a height to show all heart rates. Say 1000 points
        // there's a range of visible heart rates, defined by heartZones.minMax
        // say (90 .. 190) = 100.
        // therefore each heart rate increment is 1000 / 100, or 10 points.
        //
        // bias the heart rate by the min.  So if 90 comes in, it becomes zero,
        // if 95 comes in, 95 - min -> 95 - 90 -> becomes 5.
        // These can be negative
        //
        // to get the pixel offset, that's 5 * 10, so HR of 95 is 50 points from
        // the bottom.

        let (min, max) = heartZones.minMax()
        let range = CGFloat(max - min)
        let incrementPoints = height / range

        let biasedHeartRate = CGFloat(heartRate - Double(min))
        let pixelOffset = incrementPoints * biasedHeartRate

        let y = frame.maxY + pixelOffset

        return y
    }

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard let first = self.values.first else { return }
                
                var y = self.transform(heartRate: first,
                    height: geometry.size.height,
                    frame: geometry.frame(in: .local))
                path.move(to: CGPoint(x: CGFloat(0), y: y))
                
                for i in 1 ..< self.values.count {
                    y = self.transform(heartRate: self.values[i],
                        height: geometry.size.height,
                        frame: geometry.frame(in: .local))
                    path.addLine(to: CGPoint(x: CGFloat(2 + i * 5), y: y))
                }
            }
            .stroke(Color.black, lineWidth: 3)
        }
    }
}
