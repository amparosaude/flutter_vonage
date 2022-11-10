package br.com.mazingdev.flutter_vonage.config

enum class SdkState {
    loggedOut,
    loggedIn,
    wait,
    error,
    streamReceived,
}