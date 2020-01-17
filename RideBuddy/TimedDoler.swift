import Foundation
import Combine

let broadcastTime: TimeInterval = 0.25

class TimedDoler {
    let timerPublisher = Timer.TimerPublisher(interval: broadcastTime, runLoop: .main, mode: .default)

    var _dataSource: NumericPublisher? = nil
    var dataSource: NumericPublisher { return _dataSource! }
    
    var doubleValues: [Double] = []
    var currentIndex = 0

    func populateIntValues(_ filename: String) {
        if let url = Bundle.main.url(forResource: filename, withExtension: "csv") {
            if let blob = try? String(contentsOf: url) {
                let lines = blob.split(separator: "\n")
                for line in lines {
                    let fields = line.split(separator: ",")
                    if let doubleValue = Double(String(fields[0])) {
                        doubleValues.append(doubleValue)
                    }
                }
            }
        }
    }

    static var shared = { TimedDoler(csvName: "sample-rates") }()

    init(csvName filename: String) {
        _dataSource = timerPublisher
        .autoconnect()
        .map { (date: Date) -> Double in
            let value = self.doubleValues[self.currentIndex]
            self.currentIndex += 1
            if self.currentIndex >= self.doubleValues.count { self.currentIndex = 0 }

            return value
        }
        .multicast { PassthroughSubject<Double, Never>() }
        .autoconnect() // both .autoconnects seem to be necessary
        .eraseToAnyPublisher()

        populateIntValues(filename)
    }

}


class TimedRollingDoler {
    let timerPublisher = Timer.TimerPublisher(interval: broadcastTime, runLoop: .main, mode: .default)

    var _dataSource: NumericArrayPublisher? = nil
    var dataSource: NumericArrayPublisher { return _dataSource! }
    
    var doubleValues: [Double] = []
    var currentIndex = 0

    func populateIntValues(_ filename: String) {
        if let url = Bundle.main.url(forResource: filename, withExtension: "csv") {
            if let blob = try? String(contentsOf: url) {
                let lines = blob.split(separator: "\n")
                for line in lines {
                    let fields = line.split(separator: ",")
                    if let doubleValue = Double(String(fields[0])) {
                        doubleValues.append(doubleValue)
                    }
                }
            }
        }
    }

    static var shared = { TimedRollingDoler(csvName: "sample-rates") }()

    var window: [Double] = []
    let windowSize = 50

    init(csvName filename: String) {
        _dataSource = timerPublisher
        .autoconnect()
        .map { (date: Date) -> [Double] in

            let value = self.doubleValues[self.currentIndex]
            self.currentIndex += 1
            
            if self.currentIndex >= self.doubleValues.count {
                self.currentIndex = 0
            }

            if self.window.count >= self.windowSize {
                self.window.removeLast(self.window.count - self.windowSize)
            }
            if self.window.count > 0 && self.window.count == self.windowSize {
                self.window.removeFirst()
            }

            self.window += [value]

            return self.window
        }
//        .multicast { PassthroughSubject<[Double], Never>() }
//        .autoconnect() // both .autoconnects seem to be necessary
        .eraseToAnyPublisher()

        populateIntValues(filename)
    }

}
