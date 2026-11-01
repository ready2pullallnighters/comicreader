import UIKit                                                                                    // uikit navigation controller

// 10/31/26 navigation controller with the TinyView nav bar look from Figma
final class app_navigation_controller: UINavigationController {                                // used for the main stack and the add or edit sheets

    override var childForStatusBarStyle: UIViewController? {                                    // let each screen pick a light or dark status bar
        return topViewController                                                                // the screen on top decides
    }                                                                                           // end childForStatusBarStyle

    override func viewDidLoad() {                                                               // runs once when the controller loads
        super.viewDidLoad()                                                                     // let uikit do its setup first
        navigationBar.prefersLargeTitles = true                                                 // big titles like the Figma Home and Library screens
        navigationBar.tintColor = app_theme.accent_color                                        // terracotta back and bar buttons
        let bar_appearance = UINavigationBarAppearance()                                        // shared bar look
        bar_appearance.configureWithOpaqueBackground()                                          // solid bar
        bar_appearance.backgroundColor = app_theme.background_color                             // same color as the screen so the bar blends in
        bar_appearance.shadowColor = .clear                                                     // no hairline under the bar
        bar_appearance.titleTextAttributes = [.foregroundColor: app_theme.ink_color, .font: UIFont.systemFont(ofSize: 17, weight: .semibold)]    // small title style
        bar_appearance.largeTitleTextAttributes = [.foregroundColor: app_theme.ink_color, .font: UIFont.systemFont(ofSize: 34, weight: .bold)]    // large title style
        navigationBar.standardAppearance = bar_appearance                                       // after scrolling
        navigationBar.scrollEdgeAppearance = bar_appearance                                     // at the top of the scroll
        navigationBar.compactAppearance = bar_appearance                                        // landscape
    }                                                                                           // end viewDidLoad
}                                                                                               // end app_navigation_controller
