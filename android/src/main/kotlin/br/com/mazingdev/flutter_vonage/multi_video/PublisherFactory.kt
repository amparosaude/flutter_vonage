package br.com.mazingdev.flutter_vonage.multi_video

import android.content.Context
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class PublisherFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    companion object {
        private lateinit var view: PublisherView

        fun getViewInstance(context: Context?):PublisherView {
            if(!this::view.isInitialized) {
                view = context?.let { PublisherView(it) }!!
            }

            return view
        }
    }
    override fun create(context: Context?, viewId: Int, args: Any?): PublisherView {
        return getViewInstance(context)
    }
}