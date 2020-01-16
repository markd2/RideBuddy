# Tuesday January 14, 2020

At HBM with Mikey!

* made new project / repo, copied over design docs from BuddyKit repo
* sketched out rough diagrams

----------

Step one - connect with ride journal and log in.
Logging in gives the user payload, scheduled classes.
I don't think it has a token that it uses for subsequent uploads,
but includes username and password for say uploading stuff.

What to call this bit?  It'll be one of two(?) pipelines for Ride Journal.
RideJournal for now.

Added a LoginView with the username/password text field and the
lob-in button.

work orgy fleshing in the networking and processing pipeline, plus
error handling.  Pretty spif

==================================================
# Wednesday January 15, 2020

Timebox adding blootoof HRM to the app this morning.  found a 
wenderlich tutorial 

https://www.raywenderlich.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor

what we do there:

* add Core Bluetoof framework
* import CoreBluetooth

stup out the cbcentral mangler delegate

```
extension HRMViewController: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("central mangler did update state \(central.state)")

        switch central.state {
        case .unknown:
            print("unknown")
        case .resetting:
            print("resetting")
        case .unsupported:
            print("unsupported")
        case .unauthorized:
            print("unauthorized")
        case .poweredOff:
            print("poweredOff")
        case .poweredOn:
            print("poweredOn")
    }
  }

}
```

make a mangler

```
    var centralManager: CBCentralManager?
```

then create it

```
        centralManager = CBCentralManager(delegate: self, queue: nil)
```

Add NSBluetoothAlwaysUsageDescription to the Info(e).plist

get a .poweredOn state. Turning off bluetoof results in .poweredOff, and
a system-provided alert to turn it on.  (then .poweredOn happens)

next, scan for peripherals.  can only do that when we move to the
poweredOn state.

```
        case .poweredOn:
            print("poweredOn")
            centralManager?.scanForPeripherals(withServices: nil)
        }
```

and then this delegate gets called

```
    func centralManager(_ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber) {
        print("did discover \(peripheral)")
    }
```

that scans for all the things.

Services specification page: 
  https://www.bluetooth.com/specifications/gatt/services


HRM CBUUID is '0x180D

```
            let heartRateServiceCBUUID = CBUUID(string: "0x180D")
            centralManager?.scanForPeripherals(withServices: [heartRateServiceCBUUID])
'
```

nice.  Will get 

```
   did discover <CBPeripheral: 0x283b0c140, 
        identifier = 251807C7-A041-9D45-63E2-763533761B1A, 
        name = TICKR, state = disconnected>
```

so hang on to that (or an array of them - here it's just one)

```
    var heartRatePeripheral: CBPeripheral!
```

when found, store a reference and stop scanning.

----------

to get data need to *connect* to it, via

```
        centralManager?.connect(heartRatePeripheral)
```

and this delegate gets called 

```
    func centralManager(_ central: CBCentralManager,
        didConnect peripheral: CBPeripheral) {
        print("did connect!")
    }
```

after connecting, call discoverServices(nil) to discover services.

```
        heartRatePeripheral.discoverServices(nil)
```

and get an API misuse - need peripheral:didDiscoverService

so hook up the delegate before discovering

```
        heartRatePeripheral.delegate = self
        heartRatePeripheral.discoverServices(nil)
```

and add the delegate callback

```
extension HRMViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("tentacles!")

        guard let services = peripheral.services else {
            return print("did not find services?")
        }

        services.forEach {
            print($0)
        }
    }
}
```

which gives (for the wahoo HRM)

```
<CBService: 0x283434800, isPrimary = YES, UUID = Battery>
<CBService: 0x283434600, isPrimary = YES, UUID = Device Information>
<CBService: 0x2834345c0, isPrimary = YES, UUID = A026EE01-0A7D-4AB3-97FA-F1500F9FEB8B>
<CBService: 0x283435640, isPrimary = YES, UUID = A026EE03-0A7D-4AB3-97FA-F1500F9FEB8B>
<CBService: 0x283435680, isPrimary = YES, UUID = Heart Rate>
```

to get the services interested in, can pass those CBUUIDs to discoverServices

not the printed ones, but instead hard to find values.  Ended up using
  https://medium.com/@avigezerit/bluetooth-low-energy-on-android-22bc7310387a

only found in their final project

let heartRateServiceCBUUID = CBUUID(string: "0x180D")
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "2A37")
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "2A38")

Finally!

```
        let heartRateServiceCBUUID = CBUUID(string: "0x180D")
        let batteryServiceCBUUID = CBUUID(string: "0x180F")
        // battery level 0x2A19
        let allTheThings = [heartRateServiceCBUUID, batteryServiceCBUUID]

        heartRatePeripheral.discoverServices(allTheThings)
```

that causes the `didDiscoverServices` to get called

----------

to get the characterists, you'll need to reqeuest the discovery of the
characteristics

```
        services.forEach {
            print($0, $0.uuid)
            print("   .. discovering characteristics")
            peripheral.discoverCharacteristics(nil, for: $0)
        }
```

and of course another delegate method

```
    func peripheral(_ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?) {
        guard let characteristics = service.characteristics else {
            return print("did not find characteristics")
        }

        for characteristic in characteristics {
            print(characteristic)
        }
    }
```
got

```
<CBCharacteristic: 0x280e8bd20, UUID = 2A37, properties = 0x10, value = (null), notifying = NO>
<CBCharacteristic: 0x280e8be40, UUID = 2A38, properties = 0x2, value = (null), notifying = NO>
<CBCharacteristic: 0x280e98120, UUID = Battery Level, properties = 0x12, value = (null), notifying = NO>
```

characteristics section of the BT spec:
  https://www.bluetooth.com/specifications/gatt/characteristics

0x2A37 - org.bluetooth.characteristic.heart_rate_measurement
0x2A38 - org.bluetooth.characteristic.body_sensor_location

Added constants for these

```
let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "0x2A37")
let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "0x2A38")
```

look at the properties - .read and .notify

heart rate has .notify.  sensor location has .read. battery both.

need to subscribe to receive updates for .notify.  

----------

First, accessing the .read dealie

```
            if characteristic.properties.contains(.read) {
                print("    has .read")
                peripheral.readValue(for: characteristic)
            }
```

and of course another delegate method

```
    func peripheral(_ peripheral: CBPeripheral, 
        didUpdateValueFor characteristic: CBCharacteristic,
                error: Error?) {
        switch characteristic.uuid {
        case bodySensorLocationCharacteristicCBUUID:
            print("location has value", characteristic.value?.hexDescription ?? "no value")
        case batteryLevelCharacteristicCBUUID:
            print("battery has value", characteristic.value?.hexDescription ?? "no value")
        default:
            print("unhandled uuid has value \(characteristic.value?.hexDescription)")

        }
    }
```

and got values:

```
location has value 01
battery has value 5f
```

chest is 01


----------

Now for the heart rate

since the HR has .notify, need to subscribe to receive updates from it.

`setNotifyValue` is the magic.

```
            if characteristic.properties.contains(.notify) {
                print("    has .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
```

and get stuff like

```
unhandled uuid 2A37 has value Optional("1655d102d302")
unhandled uuid 2A37 has value Optional("1655d902")
unhandled uuid 2A37 has value Optional("1655e002ca02")
unhandled uuid 2A37 has value Optional("1655c102")
unhandled uuid 2A37 has value Optional("1655bc02b402")
unhandled uuid 2A37 has value Optional("1655b202")
```

the RW page has a brief discussion of the binary format

basicaly a bit in the 0th byte says whether the value is 1 byte or two.
then pick up the bytes you want

```
        case heartRateMeasurementCharacteristicCBUUID:
            guard let bpm = heartRate(from: characteristic) else {
                break
            }
            print("lub-dub \(bpm)")
            onHeartRateReceived(bpm)
```

and the processing.  The UInt8 initialization with the data is pretty cool.

```
    private func heartRate(from characteristic: CBCharacteristic) -> Int? {
        guard let characteristicData = characteristic.value else {
            print("could not get heart rate characteristic data")
            return nil
        }
        let byteArray = [UInt8](characteristicData)

        let firstBitValue = byteArray[0] & 0x01
        if firstBitValue == 0 {
            // heart rate is in the second byte
            return Int(byteArray[1])
        } else {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
```

----------

Since I'm in this mode right now - what about battery level?
The blootoof folk took down their nice viewer, so we just get an xml
document :-(

What does battery level look like?

`battery has value 57`

UUID 2A19

"current charge level of a battery - 100% represents fully charged and 0% 
is fully discharged"

0x57 is 87

did see an 0x64 which is 100

----------

and that's it.  simple!

I think I won't try to Combine the whole pipeline. e.g.

scanForPeripheral
.foundPeripheral
.getCharacteristics
.subscribeToCharacteristic

but that'd be sweeeeet...  (hard part is having multiple devices
in-flight and demuxing the delegate notifications)

So for, thinking of having all this junk in a file, it grabs the first
heart rate montior, BT subscribes, and then makes a heartRate and
batteryLevel publisher.


----------

had :alot: of problems trying to use .assign to a @State field of the
view struct.  Looks like that's not possible (bummer), so made a thunk
object:

```
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
```

that's used like

```
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
```

----------

Took a nice walk up to the HBM gate, and captured heart rates. (yay iexploder)

for now, let's make two meters that subscribe to the heart rate.

also add the battery level.

----------

next up, add some meters to watch things

have a meter source that can feed MeterViews

meter source has a title, and a combine publisher that vends a string.

The meter is pretty dumb - show this title, accept this string.

Can choose meters from a collection of MeterSources.

----------

Now for some reorganizing.

Thinking can move the bluetooth ting out of the environemnt, and instead
publish a collection of MeterSources.

yep - that worked out nicely.  DefaultMeters has them for now.

==================================================
# January 16, 2020

yikes, january is half-over!  eeeeep.

Slept in a bit.

Landed the half-done chizler, wnated to get some data distribution stuff going.

Needing a good way to propoagate publishers around - so things can find 
publishers and make composite ones.  Trying the dependency container thing
that squeakytoy found.

https://quickbirdstudios.com/blog/swift-dependency-injection-service-locators/


saw this in a so post:

```
 var body: some View {
    VStack {
      Text("\(currentTime)")
    }
    .onReceive(timer.currentTimePublisher) { newCurrentTime in
      self.currentTime = newCurrentTime
    }
  }
```

I needed to do 'autoconnect' twice in the timer doler

```
    let timerPublisher = Timer.TimerPublisher(interval: 1.0, runLoop: .main, mode: .default)

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

```

without the multicast, the individual values were being round-robined amongst
multiple subscribers (that would have been hard to catch later!). with the
multicast, the pipeline never runs without both autoconnects.  TODO look at later.






