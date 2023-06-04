//
//  RoundedTrimmedCircle.swift
//  
//
//  Created by Norikazu Muramoto on 2023/06/04.
//

import SwiftUI

struct RoundedTrimmedCircle: View {
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .frame(width: 100, height: 100)
            .foregroundColor(.blue)
//            .clipShape(Capsule())
    }
}

struct RoundedTrimmedCircle_Previews: PreviewProvider {
    static var previews: some View {
        RoundedTrimmedCircle()
    }
}

