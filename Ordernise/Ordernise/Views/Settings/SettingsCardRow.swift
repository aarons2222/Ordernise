//
//  SettingsCardRow.swift
//  Ordernise
//
//  Created by Aaron Strickland on 03/09/2025.
//

import SwiftUI

struct SettingsCardRow: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?
    var leadingSystemImage: String? = nil
    var showChevron: Bool = true
    var action: (() -> Void)? = nil
    var iconColor: Color? = .appTint
    var trailingImage: String?
    
    var body: some View {
        Group {
            if let action {
                Button(action: action) { rowContent }
                    .buttonStyle(.plain)
            } else {
                rowContent
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(title))
        .modifier(SubtitleHint(subtitle: subtitle))
    }

    @ViewBuilder private var rowContent: some View {
        CustomCardView {
            HStack(spacing: 12) {
                if let leading = leadingSystemImage {
                    Image(systemName: leading)
                        .imageScale(.large)
                        .foregroundStyle(.secondary)
                        .frame(width: 28)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.text)

                    if let subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }

                Spacer()

                if showChevron {
                    Image(systemName: trailingImage ?? "chevron.right.circle")
                        .font(.title)
                        .tint(iconColor)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

private struct SubtitleHint: ViewModifier {
    let subtitle: LocalizedStringKey?
    func body(content: Content) -> some View {
        if let subtitle {
            content.accessibilityHint(Text(subtitle))
        } else {
            content
        }
    }
}
