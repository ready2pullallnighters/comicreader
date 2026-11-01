import UIKit                                                                                    // uikit app lifecycle

// 10/31/26 app entry point, the window is set up in scene_delegate.swift
@main                                                                                           // marks this class as where the app starts
final class app_delegate: UIResponder, UIApplicationDelegate {                                  // UIResponder so it sits in the responder chain

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {    // app finished launching
        return true                                                                             // nothing extra to set up yet
    }                                                                                           // end didFinishLaunching

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {    // uikit asks which scene setup to use
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)    // matches the entry in Info.plist
    }                                                                                           // end configurationForConnecting
}                                                                                               // end app_delegate
