//
//  TimeRange.swift
//  
//
//  Created by Norikazu Muramoto on 2023/06/05.
//

import Foundation

/// A representation of a range of time.
///
/// A `TimeRange` object contains two `TimeInterval` values, representing a start time and an end time.
/// This struct provides an easy way to manage and manipulate ranges of time.
///
///     let morningTime = TimeRange(start: 6 * 3600, end: 12 * 3600)
///     print(morningTime.start) // 21600.0
///     print(morningTime.end) // 43200.0
///
public struct TimeRange: Codable, Equatable, Sendable {

    /// The start time of the range, represented in seconds since midnight.
    public var start: TimeInterval

    /// The end time of the range, represented in seconds since midnight.
    public var end: TimeInterval

    /// Creates a `TimeRange` instance with the specified start and end times.
    ///
    /// - Parameters:
    ///     - start: The start time of the range in seconds since midnight.
    ///     - end: The end time of the range in seconds since midnight.
    ///
    /// - Returns: A new `TimeRange` instance.
    ///
    /// - Note: The start time should be less than the end time, and both should be within a 24 hour time period.
    ///
    public init(start: TimeInterval, end: TimeInterval) {
        self.start = start
        self.end = end
    }
}
