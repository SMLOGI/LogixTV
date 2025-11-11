//
//  SideMenuItemView.swift
//  LogixTV
//
//  Created by Pradeep  Vijay Deore on 11/11/25.
//


import SwiftUI

struct SideMenuItemView: View {
    // MARK: - Input Properties
    let isFocused: Bool
    let isExpanded: Bool
    let title: String?
    let icon: SideMenuIcon
    let width: CGFloat
    let padding: CGFloat
    let highlightColor: Color
    let textColor: Color
    let onTap: () -> Void

    // MARK: - Body
    var body: some View {
        HStack(spacing: isExpanded ? 22 : 0) {
            iconView
                .frame(width: 50, height: 50)
                .frame(
                    maxWidth: isExpanded ? nil : .infinity,
                    alignment: isExpanded ? .leading : .center
                )
                .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] }

            if isExpanded, let title = title {
                Text(title)
                    .font(.system(size: 30, weight: .medium, design: .rounded))
                    .foregroundColor(isFocused ? .black : textColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .alignmentGuide(.firstTextBaseline) { d in d[VerticalAlignment.center] }
            }
        }
        .padding(.vertical, 8)
        .frame(width: width - 2 * padding, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isFocused ? highlightColor : .clear)
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .shadow(color: isFocused ? .white.opacity(0.4) : .clear, radius: 8)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
        .onTapGesture { onTap() }
        .focusable(true)
        .compositingGroup()
    }

    // MARK: - Icon View
    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .system(let name, let color):
            Image(systemName: name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(color)
        case .remote(let url):
            CachedAsyncImage(url: url)
        }
    }
}

// MARK: - Supporting Enum
enum SideMenuIcon {
    case system(name: String, color: Color)
    case remote(url: URL)
}
