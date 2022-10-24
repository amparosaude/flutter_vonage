package br.com.mazingdev.flutter_vonage.multi_video

import android.content.Context
import android.view.View
import io.flutter.plugin.platform.PlatformView

class PublisherView(context: Context) : PlatformView {
    private val videoContainer: PublisherContainer = PublisherContainer(context)

    val mainContainer get() = videoContainer.mainContainer

    override fun getView(): View {
        return videoContainer
    }

    override fun dispose() {}
}