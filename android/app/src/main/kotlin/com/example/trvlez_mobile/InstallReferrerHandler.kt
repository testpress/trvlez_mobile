package com.example.trvlez_mobile

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception

/**
 * MethodChannel handler for querying Google Play Install Referrer details on Android.
 */
class InstallReferrerHandler(private val context: Context) : MethodChannel.MethodCallHandler {
    companion object {
        const val CHANNEL_NAME = "com.trvlez.mobile/install_referrer"
        private const val METHOD_GET_INSTALL_REFERRER = "getInstallReferrer"
        private const val ERROR_CODE_REFERRER = "REFERRER_ERROR"
        private const val ERROR_CODE_INIT = "INIT_ERROR"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == METHOD_GET_INSTALL_REFERRER) {
            fetchInstallReferrer(result)
            return
        }
        result.notImplemented()
    }

    private fun fetchInstallReferrer(result: MethodChannel.Result) {
        val mainHandler = Handler(Looper.getMainLooper())
        var isResultSubmitted = false

        fun submitResult(payload: Map<String, Any?>?) {
            if (isResultSubmitted) return
            isResultSubmitted = true
            mainHandler.post { result.success(payload) }
        }

        fun submitError(code: String, message: String) {
            if (isResultSubmitted) return
            isResultSubmitted = true
            mainHandler.post { result.error(code, message, null) }
        }

        try {
            val referrerClient = InstallReferrerClient.newBuilder(context).build()
            val stateListener = createReferrerListener(
                referrerClient = referrerClient,
                onSubmitResult = ::submitResult,
                onSubmitError = ::submitError
            )
            referrerClient.startConnection(stateListener)
        } catch (initException: Exception) {
            val message = initException.localizedMessage ?: "Failed to initialize InstallReferrerClient"
            submitError(ERROR_CODE_INIT, message)
        }
    }

    private fun createReferrerListener(
        referrerClient: InstallReferrerClient,
        onSubmitResult: (Map<String, Any?>?) -> Unit,
        onSubmitError: (String, String) -> Unit
    ): InstallReferrerStateListener {
        return object : InstallReferrerStateListener {
            override fun onInstallReferrerSetupFinished(responseCode: Int) {
                handleSetupFinished(
                    referrerClient = referrerClient,
                    responseCode = responseCode,
                    onSubmitResult = onSubmitResult,
                    onSubmitError = onSubmitError
                )
            }

            override fun onInstallReferrerServiceDisconnected() {
                // Service disconnected; subsequent attempts will reconnect
            }
        }
    }

    private fun handleSetupFinished(
        referrerClient: InstallReferrerClient,
        responseCode: Int,
        onSubmitResult: (Map<String, Any?>?) -> Unit,
        onSubmitError: (String, String) -> Unit
    ) {
        try {
            if (responseCode != InstallReferrerClient.InstallReferrerResponse.OK) {
                onSubmitResult(null)
                return
            }

            val details = referrerClient.installReferrer
            val payload = mapOf(
                "installReferrer" to details.installReferrer,
                "referrerClickTimestampSeconds" to details.referrerClickTimestampSeconds,
                "installBeginTimestampSeconds" to details.installBeginTimestampSeconds
            )
            onSubmitResult(payload)
        } catch (referrerException: Exception) {
            val errorMessage = referrerException.localizedMessage ?: "Unknown error reading referrer details"
            onSubmitError(ERROR_CODE_REFERRER, errorMessage)
        } finally {
            closeClientQuietly(referrerClient)
        }
    }

    private fun closeClientQuietly(referrerClient: InstallReferrerClient) {
        try {
            referrerClient.endConnection()
        } catch (closeException: Exception) {
            // Connection already closed or terminated
        }
    }
}
