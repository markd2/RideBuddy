import Foundation
import Combine

class TimedDoler {
    let timerPublisher = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)

    var _dataSource: DataSource? = nil
    var dataSource: DataSource { return _dataSource! }
    
    var intValues: [Int] = []
    var currentIndex = 0

    func populateIntValues() {
        intValues = [1, 2, 3, 4, 5, 6]
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

        populateIntValues()
    }

}
