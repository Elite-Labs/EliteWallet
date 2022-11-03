package com.elitewallet.cw_haven

import android.app.Activity
import android.os.AsyncTask
import android.os.Looper
import android.os.Handler
import android.os.Process

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class doAsync(val handler: () -> Unit) : AsyncTask<Void, Void, Void>() {
    override fun doInBackground(vararg params: Void?): Void? {
        Process.setThreadPriority(Process.THREAD_PRIORITY_AUDIO);
        handler()
        return null
    }
}

class CwHavenPlugin: MethodCallHandler {
  companion object {
//    val havenApi = HavenApi()
    val main = Handler(Looper.getMainLooper());

    init {
      System.loadLibrary("cw_haven")
    }

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "cw_haven")
      channel.setMethodCallHandler(CwHavenPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "setupNode") {
      val uri = call.argument("address") ?: ""
      val login = call.argument("login") ?: ""
      val password = call.argument("password") ?: ""
      val useSSL = false
      val isLightWallet = false
//      doAsync {
//        try {
//          havenApi.setNodeAddressJNI(uri, login, password, useSSL, isLightWallet)
//          main.post({
//            result.success(true)
//          });
//        } catch(e: Throwable) {
//          main.post({
//            result.error("CONNECTION_ERROR", e.message, null)
//          });
//        }
//      }.execute()
    }
    if (call.method == "startSync") {
//      doAsync {
//        havenApi.startSyncJNI()
//        main.post({
//          result.success(true)
//        });
//      }.execute()
    }
    if (call.method == "loadWallet") {
      val path = call.argument("path") ?: ""
      val password = call.argument("password") ?: ""
//      havenApi.loadWalletJNI(path, password)
      result.success(true)
    }
  }
}
