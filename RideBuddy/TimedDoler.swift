import Foundation
import Combine

class TimedDoler {
    let timerPublisher = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)

    var _dataSource: DataSource? = nil
    var dataSource: DataSource { return _dataSource! }
    
    var intValues: [Int] = []
    var currentIndex = 0

    func populateIntValues(_ filename: String) {
        if let url = Bundle.main.url(forResource: filename, withExtension: "csv") {
            if let blob = try? String(contentsOf: url) {
                let lines = blob.split(separator: "\n")
                for line in lines {
                    let fields = line.split(separator: ",")
                    if let intValue = Int(String(fields[0])) {
                        intValues.append(intValue)
                    }
                }
            }
        }
    }

    static var shared = { TimedDoler(csvName: "sample-rates") }()

    init(csvName filename: String) {
        _dataSource = timerPublisher
        .autoconnect()
        .map { (date: Date) -> Int in
            let value = self.intValues[self.currentIndex]
            self.currentIndex += 1
            if self.currentIndex >= self.intValues.count { self.currentIndex = 0 }

            return value
        }
        .map { (value: Int) -> String in
            return String(value)
        }
        .multicast { PassthroughSubject<String, Never>() }
        .autoconnect() // both .autoconnects seem to be necessary
        .eraseToAnyPublisher()

        populateIntValues(filename)
    }

}
