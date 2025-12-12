//
//  LiveNowButton.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 12/12/25.
//

import Foundation
import SwiftUI

enum LiveButtonSize {
    case small
    case regular

    var dotSize: CGFloat {
        switch self {
        case .small: return 6
        case .regular: return 10
        }
    }

    var font: Font {
        switch self {
        case .small: return .system(size: 20.0)
        case .regular: return .system(size: 35.0)
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small: return 6
        case .regular: return 12
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .small: return 5
        case .regular: return 5
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .small: return 5
        case .regular: return 8
        }
    }
}


struct LiveNowButton: View {
    var size: LiveButtonSize = .regular
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {

                Circle()
                    .fill(Color.red)
                    .frame(width: size.dotSize, height: size.dotSize)

                Text(size == .small ? "LIVE" : "LIVE")
                    .font(size.font)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(Color.red)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
        }
        .buttonStyle(.plain)
    }
}
