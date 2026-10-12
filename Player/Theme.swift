
import SwiftUI

struct Theme: Identifiable, Equatable {
    let name: String
    let label: String

    let desktop: Color
    let faceLight: Color
    let face: Color
    let faceDark: Color
    let bevelLight: Color
    let bevelDark: Color

    let titleBackground: Color
    let titleText: Color
    let titleStripe: Color?

    let lcd: Color
    let display: Color
    let displayDim: Color

    let listBackground: Color
    let listText: Color
    let listCurrent: Color
    let select: Color

    let labelText: Color

    let buttonTop: Color
    let buttonBottom: Color
    let buttonText: Color
    let buttonHighlight: Color
    let buttonShade: Color
    let buttonOutline: Color?

    let seekFilled: Color
    let seekEmpty: Color
    let thumbTop: Color
    let thumbBottom: Color
    let thumbEdge: Color

    let lightOn: Color
    let lightOff: Color

    let buttonRadius: CGFloat
    let panelRadius: CGFloat

    var id: String { name }

    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.name == rhs.name
    }

    static func text(_ size: CGFloat, weight: Font.Weight = .regular, relativeTo style: Font.TextStyle = .body) -> Font {
        Font.custom(weight == .bold ? "Verdana-Bold" : "Verdana", size: size, relativeTo: style)
    }

    static func digits(_ size: CGFloat, relativeTo style: Font.TextStyle = .body) -> Font {
        Font.custom("CourierNewPS-BoldMT", size: size, relativeTo: style)
    }

    static func find(name: String?) -> Theme {
        all.first { $0.name == name } ?? standard
    }

    static let all: [Theme] = [standard, charcoal, steel, steelBlue, sapphire]

    static let standard = Theme(
        name: "default",
        label: "Default",
        desktop: Color(hex: 0x16161E),
        faceLight: Color(hex: 0x555570),
        face: Color(hex: 0x393950),
        faceDark: Color(hex: 0x20202C),
        bevelLight: Color(hex: 0x7D7D98),
        bevelDark: Color(hex: 0x0E0E14),
        titleBackground: Color(hex: 0x393950),
        titleText: Color(hex: 0xD9C76C),
        titleStripe: Color(hex: 0x7E6C2A),
        lcd: .black,
        display: Color(hex: 0x00E000),
        displayDim: Color(hex: 0x00A000),
        listBackground: .black,
        listText: Color(hex: 0x00E000),
        listCurrent: .white,
        select: Color(hex: 0x0000C6),
        labelText: Color(hex: 0xD9C76C),
        buttonTop: Color(hex: 0xD2D2DC),
        buttonBottom: Color(hex: 0x8C8CA0),
        buttonText: Color(hex: 0x1A1A24),
        buttonHighlight: Color(hex: 0xF0F0F6),
        buttonShade: Color(hex: 0x4A4A5C),
        buttonOutline: nil,
        seekFilled: Color(hex: 0x6D5E2A),
        seekEmpty: Color(hex: 0x2A2A1A),
        thumbTop: Color(hex: 0xE8D69A),
        thumbBottom: Color(hex: 0xB39A4C),
        thumbEdge: Color(hex: 0x6D5E2A),
        lightOn: Color(hex: 0x2CFF2C),
        lightOff: Color(hex: 0x1B3A1B),
        buttonRadius: 0,
        panelRadius: 0
    )

    static let charcoal = Theme(
        name: "charcoal",
        label: "Charcoal",
        desktop: Color(hex: 0x101213),
        faceLight: Color(hex: 0x31373B),
        face: Color(hex: 0x2C3236),
        faceDark: Color(hex: 0x262B2E),
        bevelLight: Color(hex: 0x3F454A),
        bevelDark: Color(hex: 0x08090A),
        titleBackground: Color(hex: 0x424652),
        titleText: Color(hex: 0xD3D4D7),
        titleStripe: nil,
        lcd: Color(hex: 0x08090A),
        display: Color(hex: 0xA2C1CC),
        displayDim: Color(hex: 0x7F878E),
        listBackground: Color(hex: 0x08090A),
        listText: Color(hex: 0x8CA7B1),
        listCurrent: Color(hex: 0xBDBDBD),
        select: Color(hex: 0x313540),
        labelText: Color(hex: 0xD3D4D7),
        buttonTop: Color(hex: 0xF9F9F9),
        buttonBottom: Color(hex: 0x9E9E9E),
        buttonText: Color(hex: 0x0E0E0E),
        buttonHighlight: .white,
        buttonShade: Color(hex: 0x808080),
        buttonOutline: Color(hex: 0x23282B),
        seekFilled: Color(hex: 0x3A4047),
        seekEmpty: Color(hex: 0x08090A),
        thumbTop: Color(hex: 0xDEDEDE),
        thumbBottom: Color(hex: 0x9E9E9E),
        thumbEdge: Color(hex: 0x808080),
        lightOn: Color(hex: 0xA2C1CC),
        lightOff: Color(hex: 0x252A2D),
        buttonRadius: 2,
        panelRadius: 0
    )

    static let steel = Theme(
        name: "steel",
        label: "Steel",
        desktop: Color(hex: 0x1D1D21),
        faceLight: Color(hex: 0x8E8EA2),
        face: Color(hex: 0x848496),
        faceDark: Color(hex: 0x787888),
        bevelLight: Color(hex: 0x9090A4),
        bevelDark: Color(hex: 0x1D1D21),
        titleBackground: Color(hex: 0x3B3B43),
        titleText: .white,
        titleStripe: Color(hex: 0xD3B069),
        lcd: .black,
        display: Color(hex: 0xF4F4F4),
        displayDim: Color(hex: 0xB7B7D1),
        listBackground: .black,
        listText: Color(hex: 0xB9F1B9),
        listCurrent: Color(hex: 0xF2F2F2),
        select: Color(hex: 0x6B6B6F),
        labelText: Color(hex: 0xD3B069),
        buttonTop: Color(hex: 0xA09991),
        buttonBottom: Color(hex: 0xBBB3AA),
        buttonText: Color(hex: 0x1D1D21),
        buttonHighlight: Color(hex: 0xFFF5E9),
        buttonShade: Color(hex: 0x69645F),
        buttonOutline: .black,
        seekFilled: Color(hex: 0x666673),
        seekEmpty: Color(hex: 0x313138),
        thumbTop: Color(hex: 0xFFFFFE),
        thumbBottom: Color(hex: 0xD2C9BF),
        thumbEdge: .black,
        lightOn: Color(hex: 0x00FF00),
        lightOff: Color(hex: 0x1F3A1F),
        buttonRadius: 0,
        panelRadius: 0
    )

    static let steelBlue = Theme(
        name: "steel-blue",
        label: "Steel Blue",
        desktop: steel.desktop,
        faceLight: steel.faceLight,
        face: steel.face,
        faceDark: steel.faceDark,
        bevelLight: steel.bevelLight,
        bevelDark: steel.bevelDark,
        titleBackground: steel.titleBackground,
        titleText: steel.titleText,
        titleStripe: steel.titleStripe,
        lcd: steel.lcd,
        display: steel.display,
        displayDim: steel.displayDim,
        listBackground: steel.listBackground,
        listText: Color(hex: 0x8FDCFF),
        listCurrent: steel.listCurrent,
        select: steel.select,
        labelText: steel.labelText,
        buttonTop: steel.buttonTop,
        buttonBottom: steel.buttonBottom,
        buttonText: steel.buttonText,
        buttonHighlight: steel.buttonHighlight,
        buttonShade: steel.buttonShade,
        buttonOutline: steel.buttonOutline,
        seekFilled: steel.seekFilled,
        seekEmpty: steel.seekEmpty,
        thumbTop: steel.thumbTop,
        thumbBottom: steel.thumbBottom,
        thumbEdge: steel.thumbEdge,
        lightOn: Color(hex: 0x00B4FF),
        lightOff: Color(hex: 0x10283A),
        buttonRadius: 0,
        panelRadius: 0
    )

    static let sapphire = Theme(
        name: "sapphire",
        label: "Sapphire",
        desktop: Color(hex: 0x0E1420),
        faceLight: Color(hex: 0xDCDDE4),
        face: Color(hex: 0xBDC3CE),
        faceDark: Color(hex: 0x8A92A0),
        bevelLight: Color(hex: 0xF6F6F8),
        bevelDark: Color(hex: 0x5D6572),
        titleBackground: Color(hex: 0x1C2C51),
        titleText: Color(hex: 0xEEEFF2),
        titleStripe: nil,
        lcd: Color(hex: 0x284A89),
        display: .white,
        displayDim: Color(hex: 0xBFCFF0),
        listBackground: Color(hex: 0x1C3D7D),
        listText: Color(hex: 0xF5F6F9),
        listCurrent: Color(hex: 0xB2CAF8),
        select: Color(hex: 0x6788C9),
        labelText: Color(hex: 0xEEEFF2),
        buttonTop: .white,
        buttonBottom: Color(hex: 0xA8AFBC),
        buttonText: Color(hex: 0x141415),
        buttonHighlight: .white,
        buttonShade: Color(hex: 0x8D93A2),
        buttonOutline: Color(hex: 0x3E4551),
        seekFilled: Color(hex: 0x406ABA),
        seekEmpty: Color(hex: 0x616976),
        thumbTop: .white,
        thumbBottom: Color(hex: 0xBEC4CF),
        thumbEdge: Color(hex: 0x3E4551),
        lightOn: .white,
        lightOff: Color(hex: 0x284173),
        buttonRadius: 9,
        panelRadius: 3
    )
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

struct SettingsResponse: Decodable {
    let settings: [String: String]
}

struct SettingUpdate: Encodable {
    struct Setting: Encodable {
        let value: String
    }

    let setting: Setting
}

@MainActor
final class ThemeStore: ObservableObject {
    @Published private(set) var theme: Theme

    private static let savedNameKey = "themeName"

    init() {
        theme = Theme.find(name: UserDefaults.standard.string(forKey: Self.savedNameKey))
    }

    func select(_ theme: Theme, using networkManager: NetworkManager) {
        apply(theme)
        Task {
            await save(theme, using: networkManager)
        }
    }

    func load(using networkManager: NetworkManager) async {
        guard let url = URL(string: "\(networkManager.baseUrl)/api/settings") else { return }

        do {
            let (data, response) = try await URLSession.shared.data(for: networkManager.authorizedRequest(url: url))

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Load settings failed, HTTP Status Code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return
            }

            let body = try JSONDecoder().decode(SettingsResponse.self, from: data)
            if let name = body.settings["theme"] {
                apply(Theme.find(name: name))
            }
        } catch {
            print("Load settings failed: \(error)")
        }
    }

    private func apply(_ theme: Theme) {
        self.theme = theme
        UserDefaults.standard.set(theme.name, forKey: Self.savedNameKey)
    }

    private func save(_ theme: Theme, using networkManager: NetworkManager) async {
        guard let url = URL(string: "\(networkManager.baseUrl)/api/settings/theme") else { return }

        var request = networkManager.authorizedRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(SettingUpdate(setting: .init(value: theme.name)))

        do {
            let (_, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                print("Save theme failed, HTTP Status Code: \(httpResponse.statusCode)")
            }
        } catch {
            print("Save theme failed: \(error)")
        }
    }
}
