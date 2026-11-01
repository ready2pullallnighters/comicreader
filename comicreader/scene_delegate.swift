import UIKit                                                                                    // uikit window and scenes

// 10/31/26 builds the window in code (no Main.storyboard) with Home as the root of the navigation stack
final class scene_delegate: UIResponder, UIWindowSceneDelegate {                                // named in Info.plist as $(PRODUCT_MODULE_NAME).scene_delegate

    var window: UIWindow?                                                                       // the app window, uikit expects this property

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {    // the scene is about to show
        guard let window_scene = scene as? UIWindowScene else { return }                        // we only support window scenes
        let new_window = UIWindow(windowScene: window_scene)                                    // window for this scene
        let navigation_controller = app_navigation_controller(rootViewController: home_view_controller())    // Home is the first screen
        new_window.rootViewController = navigation_controller                                   // show the navigation stack
        new_window.tintColor = app_theme.accent_color                                           // terracotta for every control by default
        new_window.makeKeyAndVisible()                                                          // put it on screen
        window = new_window                                                                     // keep a strong reference so it stays alive
    }                                                                                           // end willConnectTo
}                                                                                               // end scene_delegate
