package com.example.yandex_auth

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
import com.yandex.authsdk.YandexAuthException
import com.yandex.authsdk.YandexAuthLoginOptions
import com.yandex.authsdk.YandexAuthOptions
import com.yandex.authsdk.YandexAuthResult
import com.yandex.authsdk.YandexAuthSdkContract

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
    private val REQUEST_LOGIN_SDK = 52500

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "yandex_auth")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "signIn") {
            if (pendingResult != null) {
                result.error("sign_in_failed", "Concurrent operations detected", null)
                return
            }
            pendingResult = result

            val currentActivity = activity
            val currentContract = contract

            if (currentActivity == null || currentContract == null) {
                result.error("sign_in_failed", "Activity or Contract not initialized", null)
                pendingResult = null
                return
            }

            try {
                val options = YandexAuthLoginOptions()
                val intent = currentContract.createIntent(currentActivity, options)
                currentActivity.startActivityForResult(intent, REQUEST_LOGIN_SDK)
            } catch (e: Exception) {
                result.error("sign_in_failed", e.message ?: "Unknown error", null)
                pendingResult = null
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        pendingResult?.error("sign_in_failed", "Engine detached", null)
        pendingResult = null
    }

    // MARK: - ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
        activity = binding.activity
        contract = YandexAuthSdkContract(YandexAuthOptions(binding.activity, true))
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
        activity = binding.activity
        contract = YandexAuthSdkContract(YandexAuthOptions(binding.activity, true))
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activityBinding?.removeActivityResultListener(this)
        activityBinding = null
        activity = null
        contract = null
        pendingResult?.error("sign_in_failed", "Activity detached", null)
        pendingResult = null
    }

    // MARK: - ActivityResultListener

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_LOGIN_SDK) {
            val currentContract = contract
            if (currentContract == null) {
                pendingResult?.error("sign_in_failed", "Contract not initialized", null)
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
                    pendingResult?.error("sign_in_failed", "Signin failed", null)
                }
                is YandexAuthResult.Cancelled -> {
                    pendingResult?.error("sign_in_failed", "Signin cancelled", null)
                }
            }
            pendingResult = null
            return true
        }
        return false
    }
}
