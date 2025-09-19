//
//  FlowLayout.swift
//  News18AppleTV
//
//  Created by Ayush ghadekar on 02/01/25.
//

import SwiftUI
    struct FlowLayout: Layout {
        var spacing: CGFloat = 20
        @Binding var firstRowCount:Int?

        func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
            let rows = computeRows(proposal: proposal, subviews: subviews)
            let height = rows.map { $0.height }.reduce(0) { $0 + $1 + spacing }
            return CGSize(width: proposal.width ?? 0, height: max(0, height - spacing))
        }

        func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
            let rows = computeRows(proposal: proposal, subviews: subviews)
            DispatchQueue.main.async {
                firstRowCount = rows.first?.elements.count ?? 0
            }
            var y = bounds.minY
            for row in rows {
                var x = bounds.minX
                for element in row.elements {
                    element.subview.place(
                        at: CGPoint(x: x, y: y),
                        proposal: ProposedViewSize(width: element.width, height: row.height)
                    )
                    x += element.width + spacing
                }
                y += row.height + spacing
            }
        }

        private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
            var rows: [Row] = []
            var currentRow = Row()
            var x: CGFloat = 0

            let maxWidth = proposal.width ?? 0

            for subview in subviews {
                let size = subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))

                if x + size.width > maxWidth && !currentRow.elements.isEmpty {
                    rows.append(currentRow)
                    currentRow = Row()
                    x = 0
                }

                currentRow.elements.append(RowElement(subview: subview, width: size.width))
                currentRow.height = max(currentRow.height, size.height)
                x += size.width + spacing
            }

            if !currentRow.elements.isEmpty {
                rows.append(currentRow)
            }

            return rows
        }
    }

    struct Row {
        var elements: [RowElement] = []
        var height: CGFloat = 0
    }

    struct RowElement {
        let subview: LayoutSubview
        let width: CGFloat
    }
