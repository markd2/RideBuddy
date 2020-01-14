# Buddy Kit Design

## Task

[Ride Buddy Buckets](https://itunes.apple.com/us/app/ride-buddy-buckets/id1054517783?mt=8)
is an app in the store that's been there for years, starting with iOS 3, and having been
touched by a dozen of developers over the years.

It works, is fairly robust, and has happy(ish) users. But it's a
typical old obj-c frankenstein codebase, and we're wanting to add Ride Buddy
functionality to another app, ClassBuilderPlayer part of the
[iClassBuilder](https://www.iclassbuilder.com/the-class-builder-platform)
suite.

The idea is to make a framework that vends view controllers and has sensor
support and manages a ride.  Ride Buddy Buckets would be a simple life-support shell
for the framework, and the other app(s) (like iClassBuilder Player) would include the
framework and place its view controllers (e.g. sensor config, ride sheets) into their
own UI.

_What I Want To Do_ is the Grand Rewrite, with these benefits:

* Since I'm not getting paid :-) a learning platform
* Clean and extensible design
* Internalize Testing principles
* Internalize modern swift coding practices
* Use modern APIs

[Ride Buddy Buckets / Ride Journal Overview](ride-journal.md)

## Lists of Lists

### Sensors

* [Wahoo API notes](wahoo.md)
* Heart Rate (via Wahoo API)
* (bike) Speed (via Wahoo API)
* Cadence (via Wahoo API)
* Speed and Cadence (via Wahoo API)
* Keiser M3 Power (via bluetooth)
* _GPS location_ (new)

### Captured Data (from Sensors)

For the entire ride, and also per-lap

* Heart Rate
* Power (watts)
* Cadence
* Speed
* Distance

### Fetched Data

* User's Heart Zones (entered in app, or from _Ride Journal_) (see the
  [JSON payload](sample-json.md))
* Personal data for calculating calories
* Planned workouts

### Derived Data / Meters / Metrics

During a ride, the user can configure the meters on screens to show
whatever metrics they're interested in.

* Heart Rate, plus average, lap-average, max, lap-max
* Power, plus average, lap-average, max, lap-max
* Cadence, plus average, lap-average, max, lap-max
* Speed, plus average, lap-average, max, lap-max
* Current [Points](points.md)
* Lap #
* Lap Time
* Estimated calories
* Current heart zone
* Zone 1 time, target, current, left
* Zone 2 time, target, current, left
* Zone 3 time, target, current, left
* Zone 4 time, target, current, left
* Zone 5 time, target, current, left
* Current zone time, target, current, left
* Elapsed ride itme
* Remaining ride time
* _Wall-clock time_ (new)

### Custom Views

* Buckets!
* Meters
* HR Chart
* Stats table
* Ride Progress
* Keiser Console
* Keiser Keyboard

### Screens

* Check out the [screenshots](screenshots.md)
* Main Screen
* Select Planned Rides
    - Choose Plan Alternate
* Settings
    - Edit Zones
    - Edit personal info(e) for calorie calculation
* History Lists
* Ride History
    - History Bukets
    - History Stats
* Video Tutorial Player
* Diagnostic Submission Email Form
* Keiser Console Entry
* Ride Journal Preview
* Debug / Six-Tap
* About
* Ride Pages
    - 2x (meters) + chart
    - 2x + Buckts
    - 6x
    - 2x + Grid
    - 5x
    - 4x + Chart
    - (not wedded to all of these. The 5x for instance is worthless)
    - _Editor_ (new)

