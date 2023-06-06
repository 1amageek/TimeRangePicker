//
//  ClockFace.swift
//  
//
//  Created by Norikazu Muramoto on 2023/06/04.
//

import SwiftUI

struct Graduations: Shape {

    var divisions: Int

    var markLength: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let startRadians = 0 * CGFloat.pi / 180
        let endRadians = 360 * CGFloat.pi / 180
        let step = (endRadians - startRadians) / CGFloat(divisions)

        var path = Path()
        for i in 0..<divisions {
            let angle = startRadians + step * CGFloat(i)
            let tickStart = CGPoint(
                x: center.x + (radius - (i % 5 == 0 ? markLength : markLength/2)) * cos(angle),
                y: center.y + (radius - (i % 5 == 0 ? markLength : markLength/2)) * sin(angle)
            )
            let tickEnd = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            path.move(to: tickStart)
            path.addLine(to: tickEnd)
        }
        return path
    }
}

struct Dial: View {

    var range: Range<Int> = 0..<24

    var step: Int = 2

    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            ZStack {
                ForEach(stride(from: range.lowerBound, to: range.upperBound, by: step).map { $0 }, id: \.self) { i in
                    let angle = CGFloat(i / 2)
                    Text("\(i)")
                        .foregroundColor(.primary)
                        .position(
                            x: center.x + radius * cos(angle * .pi / 6 - .pi / 2),
                            y: center.y + radius * sin(angle * .pi / 6 - .pi / 2)
                        )
                }
            }
        }
    }
}

struct ClockFace: View {

    var divisions: Int

    var markLength: CGFloat

    init(divisions: Int = 60, markLength: CGFloat = 6) {
        self.divisions = divisions
        self.markLength = markLength
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Graduations(divisions: divisions, markLength: markLength)
                    .stroke(Color.secondary, style: .init(lineWidth: 2, lineCap: .round))
                Dial()
                    .padding(24)
                VStack {
                    Image(systemName: "moon.stars.fill")
                        .foregroundColor(.cyan)
                    Spacer()
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(.yellow)
                }
                .font(.title3)
                .padding(42)
                .frame(height: proxy.size.width, alignment: .center)
            }

        }
    }
}


struct ClockTicks_Previews: PreviewProvider {
    static var previews: some View {
        ClockFace()
    }
}
