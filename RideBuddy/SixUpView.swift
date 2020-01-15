import SwiftUI

struct SixUpView: View {
    @Environment(\.defaultMeters) var defaultMeters: DefaultMeterSources
    @Binding var meterSources: [MeterSource]

    @State var showingChizler = false
    @State var editingMeterIndex = 0
    @Binding var allTheMeters: [MeterSource]

    @State var chooserIndex = 0
    
    func meterAt(_ index: Int) -> MeterSource {
        return meterSources[index]
    }
    
    var body: some View {
        HStack {
            VStack {
                Button(action: {
                        self.editingMeterIndex = 0
                        self.showingChizler.toggle() 
                    }) {
                    MeterView(meterSource: meterAt(0))
                }
                Button(action: {
                        self.editingMeterIndex = 1
                        self.showingChizler.toggle() 
                    }) {
                    MeterView(meterSource: meterAt(1))
                }
                Button(action: {
                        self.editingMeterIndex = 2
                        self.showingChizler.toggle() 
                    }) {
                    MeterView(meterSource: meterAt(2))
                }
            }
            VStack {
                MeterView(meterSource: meterAt(3))
                MeterView(meterSource: meterAt(4))
                MeterView(meterSource: meterAt(5))
            }

        }.sheet(isPresented: $showingChizler) {
            VStack {
                MeterChooser(index: self.$chooserIndex, 
                    contents: self.$allTheMeters)
                Button(action: { self.showingChizler.toggle() }) {
                    Text("Snorfle - editing \(self.editingMeterIndex)")
                }
            }
        }
    }
}
