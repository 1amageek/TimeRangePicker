# TimeRangePicker

TimeRangePicker is a SwiftUI view that provides a user-friendly interface for selecting a range of time. It displays a circular clock face and allows users to select a start and end time by dragging around the clock.

## Features

- Interactive time selection using a visual clock interface.
- Customizable minimum and maximum time differences.
- Supports both light and dark mode.
- Includes Haptic feedback.

## Installation

### Swift Package Manager

You can use The Swift Package Manager to install `TimeRangePicker` by adding the proper description to your `Package.swift` file:

```swift
.package(url: "https://github.com/YOUR_GITHUB_USERNAME/TimeRangePicker.git", from: "1.0.0"),
```

## Usage

To use TimeRangePicker in your SwiftUI views:

```swift
@State var timeRange = TimeRange(start: 3600, end: 7200)  // 1:00 - 2:00

var body: some View {
    TimeRangePicker($timeRange)
}

```
