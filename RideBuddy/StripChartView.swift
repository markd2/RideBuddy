import SwiftUI

struct StripChartView: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.red)
            Rectangle().fill(Color.orange)
            Rectangle().fill(Color.yellow)
            Rectangle().fill(Color.green)
            Rectangle().fill(Color.blue)
        }
    }
}
