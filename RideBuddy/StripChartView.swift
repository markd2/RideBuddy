import SwiftUI

struct StripChartView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Rectangle().fill(Color.red)
                Rectangle().fill(Color.orange)
                Rectangle().fill(Color.yellow)
                Rectangle().fill(Color.green)
                Rectangle().fill(Color.blue)
            }
            LineChart()
        }
    }
}

struct LineChart: View {
    var body: some View {
        Path { path in
            var y: CGFloat = 100
            path.move(to: CGPoint(x: CGFloat(0), y: y))
            for i in 0...250 {
                y += CGFloat(Int.random(in: -3...3))
                path.addLine(to: CGPoint(x: CGFloat(2 + i * 3), y: y))
            }
        }
        .stroke(Color.black, lineWidth: 3)
    }
}
