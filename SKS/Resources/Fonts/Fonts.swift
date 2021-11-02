import UIKit

class OpenSans {
    // MARK: - Properties
    let regular = FontStyle.regular(fontName: "OpenSans-Regular")
    let medium = FontStyle.medium(fontName: "OpenSans-SemiBold")
    let bold = FontStyle.bold(fontName: "OpenSans-Bold")
}

class Montserrat {
    // MARK: - Properties
    let regular = FontStyle.regular(fontName: "Montserrat-Regular")
    let medium = FontStyle.medium(fontName: "Montserrat-Medium")
    let bold = FontStyle.bold(fontName: "Montserrat-Bold")
}

enum FontStyle {
    // MARK: - Cases
    case regular(fontName: String)
    case medium(fontName: String)
    case bold(fontName: String)


    // MARK: - Properties
    var s10: UIFont {
        return Fonts.loadFont(name: fontName,
                              size: 10)
    }

    var s12: UIFont {
        return Fonts.loadFont(name: fontName,
                              size: 12)
    }

    var s14: UIFont {
        return Fonts.loadFont(name: fontName,
                              size: 14)
    }

    var s16: UIFont {
        return Fonts.loadFont(name: fontName,
                              size: 16)
    }

    var s18: UIFont {
        return Fonts.loadFont(name: fontName,
                              size: 18)
    }

    var s20: UIFont {
        return Fonts.loadFont(name: fontName,
                              size: 20)
    }

    var s24: UIFont {
        return Fonts.loadFont(name: fontName,
                              size: 24)
    }

    var s32: UIFont {
        return Fonts.loadFont(name: fontName,
                              size: 32)
    }

    var s40: UIFont {
        return Fonts.loadFont(name: fontName,
                              size: 40)
    }

    private var fontName: String {
        switch self {
        case .regular(let fontName):
            return fontName
        case .bold(let fontName):
            return fontName
        case .medium(let fontName):
            return fontName
        }
    }
}

final class Fonts {
    // MARK: - Properties
    public static let openSans = OpenSans()
    public static let montserrat = Montserrat()

    // MARK: - Methods
    static func loadFont(name: String, size: CGFloat) -> UIFont {
        if let font = UIFont(name: name,
                             size: size) {
            return font
        }

        let bundle = Bundle(for: Fonts.self)

        guard let url = bundle.url(forResource: name,
                                   withExtension: "ttf"),
        let fontData = NSData(contentsOf: url),
        let provider = CGDataProvider(data: fontData),
        let cgFont = CGFont(provider),
        let fontName = cgFont.postScriptName as String? else {
            preconditionFailure("Unable to load font named \(name)")
        }

        CTFontManagerRegisterGraphicsFont(cgFont,
                                          nil)
        return UIFont(name: fontName,
                      size: size)!
    }
}
