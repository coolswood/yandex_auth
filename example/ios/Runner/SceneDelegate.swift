import Flutter
import UIKit
import YandexLoginSDK

class SceneDelegate: FlutterSceneDelegate {
    
    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        super.scene(scene, openURLContexts: URLContexts)
        guard let url = URLContexts.first?.url else { return }
        _ = YandexLoginSDK.shared.handleOpen(url)
    }
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        
        // Handle URL Contexts (URL Schemes)
        if let url = connectionOptions.urlContexts.first?.url {
            _ = YandexLoginSDK.shared.handleOpen(url)
        }
        
        // Handle User Activities (Universal Links)
        if let userActivity = connectionOptions.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            _ = YandexLoginSDK.shared.handleOpen(url)
        }
    }
    
    override func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        super.scene(scene, continue: userActivity)
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return
        }
        _ = YandexLoginSDK.shared.handleOpen(url)
    }
}

