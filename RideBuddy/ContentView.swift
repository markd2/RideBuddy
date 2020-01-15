import SwiftUI
import Combine


class HeartRateThunk: ObservableObject {
    private var subscriptions = Set<AnyCancellable>()

    @Published var heartRate: String = "---"

    init(bluetoothAccess: BlueToothAccess? = nil) {
        guard let bluetoothAccess = bluetoothAccess else {
            return
        }
        bluetoothAccess.heartRatePublisher
        .receive(on: RunLoop.main)
        .map {
            return String($0)
        }
        .assign(to: \.heartRate, on: self)
        .store(in: &subscriptions)
    }
}

struct ContentView: View {
    @ObservedObject var thunk: HeartRateThunk = HeartRateThunk()

    @Environment(\.bluetoothAccess) var bluetoothAccess: BlueToothAccess

    init() {
        thunk = HeartRateThunk(bluetoothAccess: bluetoothAccess)
    }

    var body: some View {
        Text(thunk.heartRate).font(.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



extension ContentView {
    /// Append an int value and timestamp (seconds since 1970) to a log file.
    /// It's not O_APPEND, instead seekToEndOfFile :-(  So don't even think of 
    /// using in a threaded context.
    ///
    /// not used by anybody, but useful to stick in a heart rate subscriber to
    /// capture readings for later playback.
    func writeValue(_ value: Int) {
        let string = "\(value),\(Int(Date().timeIntervalSince1970))\n"
        print("appending \(string)")
        
        let dir: URL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory,
                                                in: FileManager.SearchPathDomainMask.userDomainMask).first!
        let fileurl =  dir.appendingPathComponent("log.txt")
        
        do {
            if FileManager.default.fileExists(atPath: fileurl.path) {
                let fileHandle = try FileHandle(forUpdating: fileurl)
                fileHandle.seekToEndOfFile() // :'-(
                fileHandle.write(string.data(using: .utf8)!)
                fileHandle.closeFile()
            } else {
                if let data = string.data(using: .utf8) {
                    try? data.write(to: fileurl, options: .atomicWrite)
                }
            }
        } catch {
            print("Error writing to file \(error)")
        }
    }
}
