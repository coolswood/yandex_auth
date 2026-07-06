package com.coolswood.yandex_auth

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test

/*
 * This demonstrates a simple unit test of the Kotlin portion of this plugin's implementation.
 *
 * Once you have built the plugin's example app, you can run these tests from the command
 * line by running `./gradlew testDebugUnitTest` in the `example/android/` directory, or
 * you can run them directly from IDEs that support JUnit such as Android Studio.
 */

internal class YandexAuthPluginTest {
    @Test
    fun onMethodCall_signIn_withoutActivity_returnsError() {
        val plugin = YandexAuthPlugin()

        val call = MethodCall("signIn", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)

        Mockito.verify(mockResult).error(
            Mockito.eq("no_activity"),
            Mockito.eq("Activity or Contract not initialized"),
            Mockito.isNull()
        )
    }
}
