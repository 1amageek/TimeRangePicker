import SwiftUI
import ClockFace

/// A SwiftUI view that provides a visual picker for a range of time.
///
/// This view renders a clock face, and allows the user to select a start and end time by dragging on the clock.
/// The current time range selection is represented by `TimeRange` and can be accessed or modified by a binding.
///
/// ```
/// @State var timeRange = TimeRange(start: 3600, end: 7200)  // 1:00 - 2:00
///
/// var body: some View {
///     TimeRangePicker($timeRange)
/// }
/// ```
///
public struct TimeRangePicker: View {

    @Environment(\.colorScheme) var colorScheme: ColorScheme

    /// A binding to a `TimeRange` that determines the currently selected start and end time.
    @Binding var value: TimeRange

    @State private var initialStartAngle: CGFloat = 0

    @State private var initialEndAngle: CGFloat = 0

    var minimumDifference: CGFloat

    var maximumDifference: CGFloat

    /// Creates a `TimeRangePicker` instance with a binding to the selected range and an optional range of allowable values.
    ///
    /// - Parameters:
    ///   - value: A binding to a `TimeRange` that provides the initial start and end times and updates with any user changes.
    ///   - range: An optional range of allowable times for the user to select. The default range is from 1 hour to 22.72 hours after midnight.
    ///
    /// - Returns: A new `TimeRangePicker` instance.
    ///
    public init(_ value: Binding<TimeRange>, in range: Range<TimeInterval> = 3600..<81800) {
        self._value = value
        self.minimumDifference = CGFloat(range.lowerBound / 86400.0 * 360.0)
        self.maximumDifference = CGFloat(range.upperBound / 86400.0 * 360.0)
    }

    static func timeToAngle(_ timeInterval: TimeInterval) -> CGFloat {
        return CGFloat(timeInterval / 86400.0 * 360.0) + 270
    }

    static func angleToTime(_ angle: CGFloat) -> TimeInterval {
        return TimeInterval((angle + 90) / 360.0 * 86400.0).truncatingRemainder(dividingBy: 86400.0)
    }

    var startAngle: Binding<CGFloat> {
        Binding {
            TimeRangePicker.timeToAngle(self.value.start)
        } set: { newValue in
            self.value.start = TimeRangePicker.angleToTime(newValue).roundToNearest(300)
        }
    }

    var endAngle: Binding<CGFloat> {
        Binding {
            TimeRangePicker.timeToAngle(self.value.end)
        } set: { newValue in
            self.value.end = TimeRangePicker.angleToTime(newValue).roundToNearest(300)
        }
    }

    let generator = UIImpactFeedbackGenerator(style: .medium)

    private func gesture(proxy: GeometryProxy) -> some Gesture {
        SimultaneousGesture(
            LongPressGesture(minimumDuration: 0.0, maximumDistance: 5)
                .onEnded { value in
                    self.initialStartAngle = self.startAngle.wrappedValue
                    self.initialEndAngle = self.endAngle.wrappedValue
                },
            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                .onChanged { value in
                    let vector1 = CGVector(dx: value.startLocation.x - proxy.size.width / 2,
                                           dy: value.startLocation.y - proxy.size.height / 2)
                    let vector2 = CGVector(dx: value.location.x - proxy.size.width / 2,
                                           dy: value.location.y - proxy.size.height / 2)
                    let startAngleRad = atan2(vector1.dy, vector1.dx)
                    let endAngleRad = atan2(vector2.dy, vector2.dx)
                    let startAngleDrag = (startAngleRad < 0 ? startAngleRad + 2 * .pi : startAngleRad) * (180 / CGFloat.pi)
                    let endAngleDrag = (endAngleRad < 0 ? endAngleRad + 2 * .pi : endAngleRad) * (180 / CGFloat.pi)
                    let dragAmount = endAngleDrag - startAngleDrag
                    self.startAngle.wrappedValue = (self.initialStartAngle + dragAmount).truncatingRemainder(dividingBy: 360)
                    self.endAngle.wrappedValue = (self.initialEndAngle + dragAmount).truncatingRemainder(dividingBy: 360)
                }
                .onEnded { _ in
                    self.initialStartAngle = 0
                    self.initialEndAngle = 0
                }
        )
    }

    public var body: some View {
        ZStack {

            ClockFace(0..<24, step: 2) { index in
                Text(index, format: .number)
                    .font(.system(.callout, design: .rounded, weight: .semibold))
                    .monospacedDigit()
                    .foregroundColor(index % 3 == 0 ? .primary : .secondary)
            }
            .overlay {
                VStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(.cyan)
                    Spacer()
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.yellow)
                }
                .font(.title3)
                .padding(50)
            }
            .padding(6)
            .background(Color(UIColor.tertiarySystemBackground), in: Circle())
            .padding(28)


            GeometryReader { proxy in
                ArcTicks(startAngle: startAngle.wrappedValue, endAngle: endAngle.wrappedValue)
                    .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 0)
                    .gesture(gesture(proxy: proxy))
            }

            KnobView(angle: startAngle, offsetAngle: Double(0)) {
                Image(systemName: "power")
                    .resizable()
                    .scaledToFit()
                    .bold()
                    .padding(12)
                    .frame(width: 44, height: 44)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .clipShape(Circle())
                    .foregroundColor(.secondary)
            }

            KnobView(angle: endAngle, offsetAngle: Double(0)) {
                Image(systemName: "poweroff")
                    .resizable()
                    .scaledToFit()
                    .bold()
                    .padding(12)
                    .frame(width: 44, height: 44)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .clipShape(Circle())
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: startAngle.wrappedValue) { newValue in
            var diff = (endAngle.wrappedValue - newValue).truncatingRemainder(dividingBy: 360)
            if diff < 0 {
                diff += 360
            }
            if diff < minimumDifference {
                endAngle.wrappedValue = (newValue + minimumDifference).truncatingRemainder(dividingBy: 360)
                if endAngle.wrappedValue < 0 {
                    endAngle.wrappedValue += 360
                }
            } else if diff > maximumDifference {
                endAngle.wrappedValue = (newValue + maximumDifference).truncatingRemainder(dividingBy: 360)
                if endAngle.wrappedValue < 0 {
                    endAngle.wrappedValue += 360
                }
            }
        }
        .onChange(of: endAngle.wrappedValue) { newValue in
            var diff = (newValue - startAngle.wrappedValue).truncatingRemainder(dividingBy: 360)
            if diff < 0 {
                diff += 360
            }
            if diff < minimumDifference {
                startAngle.wrappedValue = (newValue - minimumDifference).truncatingRemainder(dividingBy: 360)
                if startAngle.wrappedValue < 0 {
                    startAngle.wrappedValue += 360
                }
            } else if diff > maximumDifference {
                startAngle.wrappedValue = (newValue - maximumDifference).truncatingRemainder(dividingBy: 360)
                if startAngle.wrappedValue < 0 {
                    startAngle.wrappedValue += 360
                }
            }
        }
        .onChange(of: value) { [previousValue = value] newValue in
            let startDifference = abs(newValue.start - previousValue.start)
            let endDifference = abs(newValue.end - previousValue.end)
            if startDifference >= 300 || endDifference >= 300 {
                generator.impactOccurred()
            }
        }
        .padding(28)
        .background(colorScheme == .light ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground), in: Circle())
    }
}

struct KnobView<Content>: View where Content: View {

    @Binding var angle: CGFloat

    var offsetAngle: CGFloat

    var content: () -> Content

    init(angle: Binding<CGFloat>, offsetAngle: CGFloat, content: @escaping () -> Content) {
        self._angle = angle
        self.offsetAngle = offsetAngle
        self.content = content
    }

    var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)
            let radius = proxy.size.width / 2
            let position = CGPoint(
                x: center.x + radius * cos((angle + offsetAngle) / 180 * .pi),
                y: center.y + radius * sin((angle + offsetAngle) / 180 * .pi)
            )
            content()
                .position(position)
                .gesture(
                    DragGesture(minimumDistance: 0.1)
                        .onChanged { value in
                            let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
                            let radians = atan2(vector.dy, vector.dx)
                            if radians < 0 {
                                self.angle = (radians + 2 * .pi) * 180 / .pi
                            } else {
                                self.angle = radians * 180 / .pi
                            }
                        }
                )
        }
    }
}

extension TimeInterval {
    func roundToNearest(_ value: TimeInterval) -> TimeInterval {
        return (self / value).rounded(.toNearestOrEven) * value
    }
}
struct TimeRangePicker_Previews: PreviewProvider {

    struct ContentView: View {

        @State var range: TimeRange = TimeRange(start: 0.0, end: 3600 * 5)

        var formatter: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad
            return formatter
        }()

        var body: some View {
            VStack {

                let _ = print(range)
                Text("TimeRangePicker")
                    .font(.system(.title, design: .rounded, weight: .black))
                HStack(spacing: 64) {
                    Text(formatter.string(from: range.start)!)
                    Text(formatter.string(from: range.end)!)
                }
                .font(.system(.title2, design: .rounded, weight: .black))
                .monospacedDigit()

                TimeRangePicker($range)
                    .frame(height: 380)

            }
            .padding()
            .background(Color(UIColor.tertiarySystemBackground))
        }
    }


    static var previews: some View {
        List {
            ContentView()
                .listRowInsets(EdgeInsets())
        }

    }
}

