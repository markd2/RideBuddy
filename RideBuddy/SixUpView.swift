import SwiftUI

struct SixUpView: View {
    @Environment(\.defaultMeters) var defaultMeters: DefaultMeterSources
    @Binding var meterSources: [MeterSource]
    
    func meterAt(_ index: Int) -> MeterSource {
        return meterSources[index]
    }
    
    var body: some View {
        HStack {
            VStack {
                MeterView(meterSource: meterAt(0))
                MeterView(meterSource: meterAt(1))
                MeterView(meterSource: meterAt(2))
            }
            VStack {
                MeterView(meterSource: meterAt(3))
                MeterView(meterSource: meterAt(4))
                MeterView(meterSource: meterAt(5))
            }
        }
    }
}
