import Flutter
import UIKit
import YandexLoginSDK

class SceneDelegate: FlutterSceneDelegate {
    
    override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        super.scene(scene, openURLContexts: URLContexts)
        for context in URLContexts {
            _ = YandexLoginSDK.shared.handleOpen(context.url)
        }
    }
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        super.scene(scene, willConnectTo: session, options: connectionOptions)
        
        // Handle URL Contexts (URL Schemes)
        for context in connectionOptions.urlContexts {
            _ = YandexLoginSDK.shared.handleOpen(context.url)
        }
        
        // Handle User Activities (Universal Links)
        for userActivity in connectionOptions.userActivities {
            if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
               let url = userActivity.webpageURL {
                _ = YandexLoginSDK.shared.handleOpen(url)
            }
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

