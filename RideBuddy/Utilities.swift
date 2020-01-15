import Foundation

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
