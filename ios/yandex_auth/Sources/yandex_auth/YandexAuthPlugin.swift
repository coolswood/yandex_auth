import Flutter
import UIKit
import YandexLoginSDK

public class YandexAuthPlugin: NSObject, FlutterPlugin, YandexLoginSDKObserver {
    private var methodResult: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "yandex_auth", binaryMessenger: registrar.messenger())
        let instance = YandexAuthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance) // Чтобы обрабатывать URL, если потребуется
        
        // Автоматически активируем YandexLoginSDK из Info.plist
        if let clientId = Bundle.main.object(forInfoDictionaryKey: "YAClientId") as? String {
            do {
                try YandexLoginSDK.shared.activate(with: clientId)
            } catch {
                print("Failed to activate YandexLoginSDK: \(error)")
            }
        } else {
            print("YAClientId key missing in Info.plist")
        }
        
        // Добавляем наблюдателя
        YandexLoginSDK.shared.add(observer: instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "signIn" {
            if methodResult != nil {
                result(FlutterError(code: "CONCURRENT_OPERATIONS", message: "Concurrent operations detected", details: nil))
                return
            }
            methodResult = result
            signIn()
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - App Delegate

    public func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return YandexLoginSDK.shared.tryHandleOpenURL(url)
    }

    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let handled = YandexLoginSDK.shared.tryHandleUserActivity(userActivity)
        if handled {
            restorationHandler([])
        }
        return handled
    }

    private func signIn() {
        var rootViewController: UIViewController? = nil
        
        if #available(iOS 13.0, *) {
            rootViewController = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }?.rootViewController
        }
        
        if rootViewController == nil {
            rootViewController = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController
        }
        
        guard let validRootViewController = rootViewController else {
            methodResult?(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Failed to find root view controller", details: nil))
            methodResult = nil
            return
        }
        
        do {
            try YandexLoginSDK.shared.authorize(with: validRootViewController)
        } catch {
            methodResult?(FlutterError(code: "YANDEX_AUTH_ERROR", message: error.localizedDescription, details: "\(error)"))
            methodResult = nil
        }
    }

    // MARK: - YandexLoginSDKObserver

    public func didFinishLogin(with result: Result<LoginResult, any Error>) {
        guard let methodResult = self.methodResult else { return }
        
        switch result {
        case .success(let loginResult):
            methodResult([
                "token": loginResult.token
            ])
        case .failure(let error):
            methodResult(FlutterError(code: "YANDEX_AUTH_ERROR", message: error.localizedDescription, details: "\(error)"))
        }
        self.methodResult = nil
    }

    // MARK: - Lifecycle Cleanup

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        YandexLoginSDK.shared.remove(observer: self)
        methodResult = nil
    }
}
