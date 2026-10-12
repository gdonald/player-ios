
import SwiftUI

struct BevelBorder: View {
    let light: Color
    let dark: Color
    var raised = true

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            Path { path in
                path.move(to: CGPoint(x: 0.5, y: height))
                path.addLine(to: CGPoint(x: 0.5, y: 0.5))
                path.addLine(to: CGPoint(x: width, y: 0.5))
            }
            .stroke(raised ? light : dark, lineWidth: 1)

            Path { path in
                path.move(to: CGPoint(x: width - 0.5, y: 0))
                path.addLine(to: CGPoint(x: width - 0.5, y: height - 0.5))
                path.addLine(to: CGPoint(x: 0, y: height - 0.5))
            }
            .stroke(raised ? dark : light, lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

struct WinampTitleBar<Accessory: View>: View {
    let theme: Theme
    let title: String
    @ViewBuilder let accessory: () -> Accessory

    var body: some View {
        ZStack {
            if let stripe = theme.titleStripe {
                VStack(spacing: 2) {
                    ForEach(0 ..< 3, id: \.self) { _ in
                        Rectangle()
                            .fill(stripe)
                            .frame(height: 1)
                    }
                }
            }

            HStack(spacing: 0) {
                Spacer(minLength: 0)

                Text(title.uppercased())
                    .font(Theme.text(10, weight: .bold, relativeTo: .caption2))
                    .tracking(1)
                    .foregroundStyle(theme.titleText)
                    .padding(.horizontal, 8)
                    .background(theme.titleBackground)

                Spacer(minLength: 0)
            }

            HStack {
                Spacer()
                accessory()
            }
            .padding(.trailing, 4)
        }
        .frame(height: 20)
        .background(theme.titleStripe == nil ? theme.titleBackground : theme.face)
    }
}

struct WinampWindow<Accessory: View, Content: View>: View {
    let theme: Theme
    let title: String
    @ViewBuilder let accessory: () -> Accessory
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            WinampTitleBar(theme: theme, title: title, accessory: accessory)

            content()
                .padding(6)
        }
        .background(
            LinearGradient(
                colors: [theme.faceLight, theme.face, theme.faceDark],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(BevelBorder(light: theme.bevelLight, dark: theme.bevelDark, raised: true))
    }
}

extension WinampWindow where Accessory == EmptyView {
    init(theme: Theme, title: String, @ViewBuilder content: @escaping () -> Content) {
        self.theme = theme
        self.title = title
        self.accessory = { EmptyView() }
        self.content = content
    }
}

struct LCDPanel: ViewModifier {
    let theme: Theme
    var background: Color?

    func body(content: Content) -> some View {
        content
            .background(background ?? theme.lcd)
            .clipShape(RoundedRectangle(cornerRadius: theme.panelRadius))
            .overlay(BevelBorder(light: theme.bevelLight, dark: theme.bevelDark, raised: false))
    }
}

struct ListRowLine: ViewModifier {
    let theme: Theme

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(theme.listText.opacity(0.15))
                    .frame(height: 1)
            }
    }
}

extension View {
    func lcdPanel(_ theme: Theme, background: Color? = nil) -> some View {
        modifier(LCDPanel(theme: theme, background: background))
    }

    func listRowLine(_ theme: Theme) -> some View {
        modifier(ListRowLine(theme: theme))
    }
}

struct BevelButtonStyle: ButtonStyle {
    let theme: Theme
    var lit = false
    var horizontalPadding: CGFloat = 10

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed || lit
        let shape = RoundedRectangle(cornerRadius: theme.buttonRadius)

        configuration.label
            .font(Theme.text(12, weight: .bold, relativeTo: .caption))
            .foregroundStyle(theme.buttonText)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 6)
            .background(
                LinearGradient(
                    colors: pressed ? [theme.buttonBottom, theme.buttonTop] : [theme.buttonTop, theme.buttonBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .clipShape(shape)
            .overlay(
                BevelBorder(light: theme.buttonHighlight, dark: theme.buttonShade, raised: !pressed)
                    .clipShape(shape)
            )
            .overlay(shape.stroke(theme.buttonOutline ?? .clear, lineWidth: 1))
    }
}

struct WinampLight: View {
    let theme: Theme
    let on: Bool

    var body: some View {
        Rectangle()
            .fill(on ? theme.lightOn : theme.lightOff)
            .frame(width: 5, height: 5)
            .overlay(Rectangle().stroke(theme.bevelDark, lineWidth: 1))
            .shadow(color: on ? theme.lightOn : .clear, radius: 2)
    }
}

struct LCDField: View {
    let theme: Theme
    let prompt: String
    @Binding var text: String
    var secure = false

    var body: some View {
        Group {
            if secure {
                SecureField("", text: $text, prompt: Text(prompt).foregroundColor(theme.displayDim))
            } else {
                TextField("", text: $text, prompt: Text(prompt).foregroundColor(theme.displayDim))
            }
        }
        .font(Theme.text(14, relativeTo: .body))
        .foregroundStyle(theme.listText)
        .tint(theme.listText)
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .lcdPanel(theme)
    }
}

struct FormLabel: View {
    let theme: Theme
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(Theme.text(11, weight: .bold, relativeTo: .caption))
            .tracking(0.5)
            .foregroundStyle(theme.labelText)
    }
}

struct ColumnHeaders: View {
    let theme: Theme
    let columns: [(title: String, width: CGFloat?)]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(columns.enumerated()), id: \.offset) { _, column in
                Text(column.title.uppercased())
                    .font(Theme.text(11, weight: .bold, relativeTo: .caption))
                    .tracking(0.5)
                    .foregroundStyle(theme.titleText)
                    .lineLimit(1)
                    .frame(width: column.width, alignment: .leading)
                    .frame(maxWidth: column.width == nil ? .infinity : nil, alignment: .leading)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 5)
        .background(theme.titleBackground)
    }
}

struct WinampToggleStyle: ToggleStyle {
    let theme: Theme

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(theme.lcd)
                    .frame(width: 16, height: 16)
                    .overlay {
                        if configuration.isOn {
                            Rectangle()
                                .fill(theme.select)
                                .padding(3)
                        }
                    }
                    .overlay(BevelBorder(light: theme.bevelLight, dark: theme.bevelDark, raised: false))

                configuration.label
                    .font(Theme.text(11, weight: .bold, relativeTo: .caption))
                    .foregroundStyle(theme.labelText)
            }
        }
        .buttonStyle(.plain)
    }
}

struct Toast: View {
    let theme: Theme
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(Theme.text(13, relativeTo: .body))
                .foregroundStyle(theme.display)
                .multilineTextAlignment(.center)
                .padding(16)
                .lcdPanel(theme)
                .transition(.opacity)
        }
    }
}
