//
//  Extensions.swift
//  News18AppleTV
//
//  Created by Mohan R on 17/10/24.
//

import Foundation
import SwiftUI
import AVFoundation
import LogixPlayerSDK

extension String {
    /// Returns a localized string for the current instance of the String.
    /// The instance itself should be the key for localization.
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }

    /// Returns a localized string for the current instance of the String with formatting arguments.
    /// - Parameter args: Arguments to format the string.
    /// - Returns: A formatted localized string.
    func localized(with args: CVarArg...) -> String {
        let format = NSLocalizedString(self, comment: "")
        return String(format: format, arguments: args)
    }

    func toFormattedDate() -> String? {
        let inputFormatter = ISO8601DateFormatter()
        let outputFormatter = DateFormatter()

        outputFormatter.dateFormat = "MMMM dd, yyyy, HH:mm"
        outputFormatter.timeZone = TimeZone(abbreviation: "IST")

        guard let date = inputFormatter.date(from: self) else {
            return nil
        }

        return outputFormatter.string(from: date)
    }
}

extension Font {
    static func robotoBold(size: CGFloat) -> Font {
        return Font.custom("Roboto-Bold", size: size)
    }

    static func robotoRegular(size: CGFloat) -> Font {
        return Font.custom("Roboto-Regular", size: size)
    }

    static func robotoLight(size: CGFloat) -> Font {
        return Font.custom("Roboto-Light", size: size)
    }
}


extension Image {
    static var placeholder: some View {
        ZStack {
            Color.gray.opacity(0.3)
                .cornerRadius(20)
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding(20)
        }
        .frame(width: 100, height: 100)
    }
}

extension UserDefaults {
    func setObject<Object: Codable>(_ object: Object, forKey key: String) {
        do {
            let data = try JSONEncoder().encode(object)
            self.set(data, forKey: key)
        } catch {
            debugPrint("Failed to encode object: \(error)")
        }
    }

    func getObject<Object: Codable>(forKey key: String, as type: Object.Type) -> Object? {
        guard let data = self.data(forKey: key) else { return nil }
        do {
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            debugPrint("Failed to decode object: \(error)")
            return nil
        }
    }
}

extension CMTime {
    var durationText: String {
        let totalSeconds = Int(CMTimeGetSeconds(self))

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func onCompatibleChange<Value: Equatable>(
        of value: Value,
        initial: Bool = false,
        perform action: @escaping (Value, Value) -> Void
    ) -> some View {
        Group {
            if #available(tvOS 17.0, *) {
                onChange(of: value, initial: initial) { oldValue, newValue in
                    action(oldValue, newValue)
                }
            } else {
                onChange(of: value) { newValue in
                    // Simulate the new API with `initial` if needed
                    if initial {
                        action(newValue, newValue) // Pass the same value as old and new
                    } else {
                        action(value, newValue)
                    }
                }
            }
        }
    }
}

extension Shape {
    func compatibleStroke<S: ShapeStyle>(
        _ content: S,
        lineWidth: CGFloat,
        antialiased: Bool = true
    ) -> some View {
        if #available(tvOS 17.0, *) {
            return AnyView(self.stroke(content, lineWidth: lineWidth, antialiased: antialiased))
        } else {
            return AnyView(self.stroke(content, lineWidth: lineWidth))
        }
    }
}

extension Array where Element == IMediaStreamQuality {
    func quality(for qualityName: VideoQualityName) -> IMediaStreamQuality? {
        switch qualityName {
        case .automatic:
            // Only consider a quality with bandwidth 0 and consumption 0.0 as Auto
            return self.first(where: { $0.bandwidth == 0 && ($0.dataConsumptionPerHourInMB ?? 0.0) == 0.0 })
        default:
            if let range = qualityName.bandwidthRange {
                // Return quality only if the bandwidth is non-zero and within range
                return self.first(where: {
                    guard let bandwidth = $0.bandwidth, bandwidth > 0 else { return false }
                    return range.contains(bandwidth)
                })
            }
            return nil
        }
    }
}

// MARK: - Extensions
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
extension String: @retroactive Identifiable {
  public var id: String { self }
}
