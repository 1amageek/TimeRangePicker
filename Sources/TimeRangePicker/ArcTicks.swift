//
//  ArcTicks.swift
//  
//
//  Created by Norikazu Muramoto on 2023/06/04.
//

import SwiftUI

struct Arc: Shape {

    var startAngle: CGFloat

    var endAngle: CGFloat

    var lineWidth: CGFloat

    init(startAngle: CGFloat, endAngle: CGFloat, lineWidth: CGFloat = 44) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.lineWidth = lineWidth
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.addArc(center: center,
                    radius: rect.width / 2,
                    startAngle: Angle(degrees: Double(startAngle)),
                    endAngle: Angle(degrees: Double(endAngle)),
                    clockwise: false)

        let roundedLine = path.strokedPath(.init(lineWidth: lineWidth, lineCap: .round))
        return roundedLine
    }
}

struct Ticks: Shape {

    var startAngle: CGFloat

    var endAngle: CGFloat

    var divisions: Int

    var tickWidth: CGFloat

    init(startAngle: CGFloat, endAngle: CGFloat, divisions: Int = 80, tickWidth: CGFloat = 14) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.divisions = divisions
        self.tickWidth = tickWidth
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2
        let startRadians = startAngle * CGFloat.pi / 180
        let endRadians = endAngle * CGFloat.pi / 180
        let step = 360.0 / CGFloat(divisions) * CGFloat.pi / 180
        var path = Path()
        for angle in stride(from: startRadians, to: endRadians, by: step) {
            let tickStart = CGPoint(
                x: center.x + (radius - tickWidth/2) * cos(angle),
                y: center.y + (radius - tickWidth/2) * sin(angle)
            )
            let tickEnd = CGPoint(
                x: center.x + (radius + tickWidth/2) * cos(angle),
                y: center.y + (radius + tickWidth/2) * sin(angle)
            )
            path.move(to: tickStart)
            path.addLine(to: tickEnd)
        }
        return path
    }
}

struct ArcTicks: View {

    var startAngle: CGFloat

    var endAngle: CGFloat

    var lineWidth: CGFloat

    var tickWidth: CGFloat

    var divisions: Int

    init(startAngle: CGFloat, endAngle: CGFloat, lineWidth: CGFloat = 44, tickWidth: CGFloat = 12, divisions: Int = 120) {
        self.startAngle = startAngle
        self.endAngle = endAngle
        self.lineWidth = lineWidth
        self.tickWidth = tickWidth
        self.divisions = divisions
    }

    var body: some View {
        ZStack {
            Arc(startAngle: startAngle, endAngle: endAngle, lineWidth: lineWidth)
                .foregroundColor(Color(UIColor.tertiarySystemBackground))
            Ticks(startAngle: 0, endAngle: 360, divisions: divisions, tickWidth: tickWidth)
                .stroke(Color(UIColor.systemGray4), style: .init(lineWidth: 4, lineCap: .round))
                .mask(Arc(startAngle: startAngle, endAngle: endAngle))
        }
        .compositingGroup()
        .contentShape(Arc(startAngle: startAngle, endAngle: endAngle))
    }
}

struct Arc_Previews: PreviewProvider {

    struct ContentView: View {

        @State var startAngle: CGFloat = 0
        @State var endAngle: CGFloat = 90
        let lineWidth: CGFloat = 40

        @GestureState private var rotation: CGFloat = 0

        var angleDifference: CGFloat {
            if startAngle > endAngle {
                return startAngle - endAngle
            } else {
                return 360 - endAngle + startAngle
            }
        }

        var body: some View {
            VStack(spacing: 32) {
                GeometryReader { proxy in
                    ArcTicks(startAngle: startAngle, endAngle: endAngle)
                        .padding(32)
                        .rotationEffect(.degrees(Double(rotation)))
                        .gesture(
                            DragGesture(minimumDistance: 0.1)
                                .updating($rotation) { value, state, _ in
                                    let vector1 = CGVector(dx: value.startLocation.x - proxy.size.width / 2,
                                                           dy: value.startLocation.y - proxy.size.height / 2)
                                    let vector2 = CGVector(dx: value.location.x - proxy.size.width / 2,
                                                           dy: value.location.y - proxy.size.height / 2)
                                    let startAngle = atan2(vector1.dy, vector1.dx) * (180 / CGFloat.pi)
                                    let endAngle = atan2(vector2.dy, vector2.dx) * (180 / CGFloat.pi)
                                    state = endAngle - startAngle
                                }
                                .onEnded { value in
                                    startAngle = (startAngle + rotation).truncatingRemainder(dividingBy: 360)
                                    endAngle = (startAngle + angleDifference).truncatingRemainder(dividingBy: 360)
                                }
                        )
                }

                Slider(value: $startAngle, in: -360...360)
                Slider(value: $endAngle, in: -360...360)
            }
        }
    }

    static var previews: some View {
        ContentView()
    }
}
