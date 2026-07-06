import AuthenticationServices
import Flutter
import UIKit
import YandexLoginSDK

/// Flutter-плагин Yandex Auth для iOS.
///
/// Стандартизованные коды ошибок (синхронизированы с Android и Dart-стороны):
/// - "activation"    — ошибка активации SDK (нет/пустой YAClientId и т.п.)
/// - "concurrent"    — повторный вызов signIn поверх активного
/// - "no_activity"   — не найден root view controller
/// - "cancelled"     — пользователь отменил авторизацию
/// - "sdk_error"     — прочая ошибка Yandex Login SDK
public class YandexAuthPlugin: NSObject, FlutterPlugin, YandexLoginSDKObserver {
    private var methodResult: FlutterResult?
    private static var activationError: String?

    public static func register(with registrar: FlutterPluginRegistrar) {
        activationError = nil // Сбрасываем состояние перед каждой регистрацией
        let channel = FlutterMethodChannel(name: Self.channelName, binaryMessenger: registrar.messenger())
        let instance = YandexAuthPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance) // Чтобы обрабатывать URL, если потребуется

        // Автоматически активируем YandexLoginSDK из Info.plist
        if let clientId = Bundle.main.object(forInfoDictionaryKey: "YAClientId") as? String {
            let trimmedClientId = clientId.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedClientId.isEmpty {
                activationError = "YAClientId in Info.plist is empty or whitespace"
            } else {
                do {
                    try YandexLoginSDK.shared.activate(with: trimmedClientId)
                } catch {
                    activationError = "Failed to activate YandexLoginSDK: \(error.localizedDescription)"
                }
            }
        } else {
            activationError = "YAClientId key missing in Info.plist"
        }

        // Добавляем наблюдателя
        YandexLoginSDK.shared.add(observer: instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "signIn" {
            if let activationError = YandexAuthPlugin.activationError {
                result(FlutterError(code: Self.errorActivation, message: activationError, details: nil))
                return
            }
            if methodResult != nil {
                result(FlutterError(code: Self.errorConcurrent, message: "Concurrent operations detected", details: nil))
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
            methodResult?(FlutterError(code: Self.errorNoActivity, message: "Failed to find root view controller", details: nil))
            methodResult = nil
            return
        }

        do {
            try YandexLoginSDK.shared.authorize(with: validRootViewController)
        } catch {
            methodResult?(FlutterError(code: Self.errorSdkError, message: error.localizedDescription, details: "\(error)"))
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
            // YandexLoginSDK сообщает об отмене через отменённый результат.
            if Self.isCancellation(error) {
                methodResult(FlutterError(code: Self.errorCancelled, message: "Signin cancelled", details: "\(error)"))
            } else {
                methodResult(FlutterError(code: Self.errorSdkError, message: error.localizedDescription, details: "\(error)"))
            }
        }
        self.methodResult = nil
    }

    /// Определяет, является ли ошибка результатом отмены авторизации пользователем.
    ///
    /// Yandex Login SDK не предоставляет публичного API для распознавания
    /// отмены, поэтому определяем её по двум сигналам:
    /// 1. ASWebAuthenticationSession (iOS 13+, основной путь) отбрасывает
    ///    ошибку домена `ASWebAuthenticationSessionErrorDomain` с кодом
    ///    `.canceledLogin`.
    /// 2. SFSafariViewController (fallback) — приватная ошибка SDK с
    ///    фиксированным сообщением о закрытии контроллера.
    private static func isCancellation(_ error: Error) -> Bool {
        let nsError = error as NSError
        if nsError.domain == ASWebAuthenticationSessionError.errorDomain {
            return nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue
        }
        let message = (error as? YandexLoginSDKError)?.message ?? ""
        return message.contains("closed the view controller")
    }

    // MARK: - Lifecycle Cleanup

    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        YandexLoginSDK.shared.remove(observer: self)
        methodResult = nil
    }

    // MARK: - Constants

    private static let channelName = "yandex_auth"
    private static let errorActivation = "activation"
    private static let errorConcurrent = "concurrent"
    private static let errorNoActivity = "no_activity"
    private static let errorCancelled = "cancelled"
    private static let errorSdkError = "sdk_error"
}
