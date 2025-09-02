import SwiftUI

struct HeaderWithButton: View {
    // Read the saved tint directly
    @AppStorage("userTintHex") private var tintHex: String = "#ACCDFF"
    private var tintColor: Color { Color(hex: tintHex) ?? .color1 }

    let title: String
    let buttonContent: String
    let isButtonImage: Bool
    let showTrailingButton: Bool
    let showLeadingButton: Bool
    let isButtonDisabled: Bool
    let onButtonTap: (() -> Void)?
    let onLeadingButtonTap: (() -> Void)?

    init(
        title: String,
        buttonContent: String,
        isButtonImage: Bool = false,
        showTrailingButton: Bool = true,
        showLeadingButton: Bool = true,
        isButtonDisabled: Bool = false,
        onButtonTap: (() -> Void)? = nil,
        onLeadingButtonTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.buttonContent = buttonContent
        self.isButtonImage = isButtonImage
        self.showTrailingButton = showTrailingButton
        self.showLeadingButton = showLeadingButton
        self.isButtonDisabled = isButtonDisabled
        self.onButtonTap = onButtonTap
        self.onLeadingButtonTap = onLeadingButtonTap
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(alignment: .center) {
            if showLeadingButton {
                Button {
                    if let onLeadingButtonTap { onLeadingButtonTap() } else { dismiss() }
                } label: {
                    Image(systemName: "chevron.backward.circle")
                        .font(.title)
                }
                .tint(tintColor)
                .padding(.leading)
            }

            Text(title)
                .font(.title)
                .lineLimit(2)
                .minimumScaleFactor(0.2)
                .truncationMode(.tail)
                .padding(.horizontal, showLeadingButton ? 5 : 15)

            Spacer()

            if showTrailingButton {
                Button {
                    onButtonTap?()
                } label: {
                    if isButtonImage {
                        Image(systemName: buttonContent)
                            .font(.title)
                    } else {
                        Text(buttonContent)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
                .tint(tintColor)
                .disabled(isButtonDisabled)
                .opacity(isButtonDisabled ? 0.45 : 1)
                .padding(.horizontal)
            }
        }
        .frame(height: 50)
    }
}
