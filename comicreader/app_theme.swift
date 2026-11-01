import UIKit                                                                                    // uikit gives us colors, fonts and views

// 10/31/26 shared colors, fonts and small view helpers, values pulled from the TinyView Figma file
enum app_theme {                                                                                // enum with no cases so nobody can make an instance, it is just a namespace

    static func hex_color(_ hex_value: UInt32, alpha: CGFloat = 1) -> UIColor {                 // turns 0xRRGGBB into a UIColor so we can paste Figma hex codes
        let red_part = CGFloat((hex_value >> 16) & 0xff) / 255                                  // top byte is red
        let green_part = CGFloat((hex_value >> 8) & 0xff) / 255                                 // middle byte is green
        let blue_part = CGFloat(hex_value & 0xff) / 255                                         // bottom byte is blue
        return UIColor(red: red_part, green: green_part, blue: blue_part, alpha: alpha)          // build the color
    }                                                                                           // end hex_color

    static let background_color = hex_color(0xF8F7F4)                                           // warm off white screen background
    static let card_color = hex_color(0xF3F1EC)                                                 // continue reading card background
    static let surface_color = UIColor.white                                                    // white groups, cells and buttons
    static let border_color = hex_color(0xDCD9D0)                                               // thin borders and separators
    static let fill_color = hex_color(0xECEBE6)                                                 // segmented control and search field fill
    static let ink_color = hex_color(0x292A28)                                                  // main text color
    static let muted_color = hex_color(0x777872)                                                // secondary text color
    static let placeholder_color = hex_color(0xA3A49D)                                          // placeholder text color
    static let accent_color = hex_color(0xB96543)                                               // terracotta buttons and links
    static let reader_background_color = hex_color(0x191B1D)                                    // dark reader background
    static let reader_bar_color = hex_color(0x191B1D, alpha: 0.94)                              // reader top and bottom bars
    static let paper_color = hex_color(0xF3EFE4)                                                // comic page paper
    static let panel_border_color = hex_color(0x283F42)                                         // comic panel outline
    static let balloon_color = hex_color(0xFBF8EA)                                              // speech balloon fill
    static let narration_color = hex_color(0xF6F0DE)                                            // narration box fill
    static let balloon_ink_color = hex_color(0x293A38)                                          // speech balloon text
    static let page_ink_color = hex_color(0x74736B)                                             // running head and page number text

    static func serif_font(size: CGFloat, italic: Bool = false) -> UIFont {                     // serif font for comic lettering, stands in for Lora from the Figma file
        var font_descriptor = UIFont.systemFont(ofSize: size).fontDescriptor                    // start from the system font
        if let serif_descriptor = font_descriptor.withDesign(.serif) {                          // ask for the serif design (New York)
            font_descriptor = serif_descriptor                                                  // use it if it exists
        }                                                                                       // end serif check
        if italic, let italic_descriptor = font_descriptor.withSymbolicTraits(.traitItalic) {   // add italic when asked
            font_descriptor = italic_descriptor                                                 // use the italic version
        }                                                                                       // end italic check
        return UIFont(descriptor: font_descriptor, size: size)                                  // build the font
    }                                                                                           // end serif_font

    static func make_label(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = app_theme.ink_color, lines: Int = 1) -> UILabel {    // one line label factory so every screen uses the same fonts
        let label = UILabel()                                                                   // new label
        label.text = text                                                                       // set the text
        label.font = UIFont.systemFont(ofSize: size, weight: weight)                            // system font at the Figma size and weight
        label.textColor = color                                                                 // text color
        label.numberOfLines = lines                                                             // 0 means wrap as much as needed
        label.adjustsFontForContentSizeCategory = true                                          // play nice with dynamic type
        return label                                                                            // hand it back
    }                                                                                           // end make_label

    static func style_group(_ view: UIView, corner_radius: CGFloat) {                           // white rounded box with a thin border, used for cards and form groups
        view.backgroundColor = surface_color                                                    // white fill
        view.layer.cornerRadius = corner_radius                                                 // round the corners
        view.layer.borderWidth = 1                                                              // 1 point border
        view.layer.borderColor = border_color.cgColor                                           // light border color
        view.layer.cornerCurve = .continuous                                                    // smooth apple style corners
        view.clipsToBounds = true                                                               // keep children inside the rounded corners
    }                                                                                           // end style_group

    static func make_separator() -> UIView {                                                    // 1 point line between rows
        let separator_view = UIView()                                                           // plain view
        separator_view.backgroundColor = border_color                                           // same color as the borders
        separator_view.translatesAutoresizingMaskIntoConstraints = false                        // we use auto layout
        separator_view.heightAnchor.constraint(equalToConstant: 1).isActive = true              // always 1 point tall
        return separator_view                                                                   // hand it back
    }                                                                                           // end make_separator

    static func cover_image(named image_name: String?) -> UIImage? {                            // looks up a cover in the asset catalog, falls back to a book symbol
        if let image_name, let cover = UIImage(named: image_name) {                             // the book has a cover in Assets.xcassets
            return cover                                                                        // use it
        }                                                                                       // end cover check
        return UIImage(systemName: "book.closed")                                               // placeholder for books added in the app
    }                                                                                           // end cover_image
}                                                                                               // end app_theme
