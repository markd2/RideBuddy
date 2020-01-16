import SwiftUI

struct MeterChooser: View {
    @Binding var index: Int
    @Binding var contents: [MeterSource]

    var body: some View {
        Picker("", selection: $index) {
            ForEach(0 ..< contents.count) { index in
                Text(self.contents[index].name)
            }
        }
    }
}
