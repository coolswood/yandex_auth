package com.coolswood.yandex_auth

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import com.yandex.authsdk.YandexAuthLoginOptions
import com.yandex.authsdk.YandexAuthOptions
import com.yandex.authsdk.YandexAuthResult
import com.yandex.authsdk.YandexAuthSdkContract

/**
 * Flutter-плагин Yandex Auth для Android.
 *
 * Стандартизованные коды ошибок (синхронизированы с iOS и Dart-стороны):
 * - "cancelled"      — пользователь отменил авторизацию
 * - "concurrent"     — повторный вызов signIn поверх активного
 * - "no_activity"    — Activity/Contract не инициализированы
 * - "sdk_error"      — ошибка Yandex Login SDK
 */
class YandexAuthPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var contract: YandexAuthSdkContract? = null
    private var pendingResult: Result? = null
    private var activityBinding: ActivityPluginBinding? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "signIn") {
            if (pendingResult != null) {
                result.error(ERROR_CONCURRENT, "Concurrent operations detected", null)
                return
            }
            pendingResult = result

            val currentActivity = activity
            val currentContract = contract

            if (currentActivity == null || currentContract == null) {
                result.error(ERROR_NO_ACTIVITY, "Activity or Contract not initialized", null)
                pendingResult = null
                return
            }

            try {
                val options = YandexAuthLoginOptions()
                val intent = currentContract.createIntent(currentActivity, options)
                currentActivity.startActivityForResult(intent, REQUEST_LOGIN_SDK)
            } catch (e: Exception) {
                result.error(ERROR_SDK_ERROR, e.message ?: "Unknown error", null)
                pendingResult = null
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        pendingResult?.error(ERROR_SDK_ERROR, "Engine detached", null)
        pendingResult = null
    }

    // MARK: - ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        attachTo(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        // Note: при config change мы НЕ очищаем pendingResult — результат
        // активити будет доставлен в новую активити после onReattached.
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        attachTo(binding)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        activity = null
        contract = null
        pendingResult?.error(ERROR_NO_ACTIVITY, "Activity detached", null)
        pendingResult = null
    }

    private fun attachTo(binding: ActivityPluginBinding) {
        activityBinding = binding
        activity = binding.activity
        contract = YandexAuthSdkContract(YandexAuthOptions(binding.activity, true))
        binding.addActivityResultListener(this)
    }

    // MARK: - ActivityResultListener

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_LOGIN_SDK) {
            val currentContract = contract
            if (currentContract == null) {
                pendingResult?.error(ERROR_NO_ACTIVITY, "Contract not initialized", null)
                pendingResult = null
                return true
            }

            val authResult = currentContract.parseResult(resultCode, data)
            when (authResult) {
                is YandexAuthResult.Success -> {
                    val token = authResult.token
                    val response = mapOf(
                        "token" to token.value,
                        "expiresIn" to token.expiresIn
                    )
                    pendingResult?.success(response)
                }
                is YandexAuthResult.Failure -> {
                    val exception = authResult.exception
                    pendingResult?.error(
                        ERROR_SDK_ERROR,
                        exception.message ?: "Signin failed",
                        exception.toString()
                    )
                }
                is YandexAuthResult.Cancelled -> {
                    pendingResult?.error(ERROR_CANCELLED, "Signin cancelled", "Cancelled by user")
                }
            }
            pendingResult = null
            return true
        }
        return false
    }

    private companion object {
        const val CHANNEL_NAME = "yandex_auth"
        const val REQUEST_LOGIN_SDK = 52500
        const val ERROR_CANCELLED = "cancelled"
        const val ERROR_CONCURRENT = "concurrent"
        const val ERROR_NO_ACTIVITY = "no_activity"
        const val ERROR_SDK_ERROR = "sdk_error"
    }
}
