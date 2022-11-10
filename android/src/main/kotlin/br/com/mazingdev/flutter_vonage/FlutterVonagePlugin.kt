package br.com.mazingdev.flutter_vonage

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import br.com.mazingdev.flutter_vonage.R
import br.com.mazingdev.flutter_vonage.config.SdkState
import br.com.mazingdev.flutter_vonage.multi_video.*
import com.opentok.android.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FlutterVonagePlugin */
class FlutterVonagePlugin: FlutterPlugin, MethodCallHandler, FlutterActivity() {
  val multiVideoMethodChannel = "com.vonage.multi_video"

  private var multiVideo: MultiVideo? = null
  private lateinit var context: Context
  private lateinit var channel : MethodChannel
  private lateinit var flutterEngine: FlutterEngine

  private var session: Session? = null
  private var publisher: Publisher? = null
  private val subscribers = ArrayList<Subscriber>()
  private val subscriberStreams = HashMap<Stream, Subscriber>()

  private lateinit var multiVideoPlatformView: MultiVideoPlatformView
  private lateinit var publisherFactory: PublisherFactory
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_vonage")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.getApplicationContext();
    multiVideoPlatformView = MultiVideoFactory.getViewInstance(context)
    flutterEngine = flutterPluginBinding.getFlutterEngine()
    publisherFactory = PublisherFactory()
    flutterEngine
      .platformViewsController
      .registry
      .registerViewFactory("opentok-multi-video-container", MultiVideoFactory())
    flutterEngine
      .platformViewsController
      .registry
      .registerViewFactory("publisher-opentok-multi-video-container", publisherFactory)


    addFlutterChannelListener()
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "initSession") {
      val apiKey = requireNotNull(call.argument<String>("apiKey"))
      val sessionId = requireNotNull(call.argument<String>("sessionId"))
      val token = requireNotNull(call.argument<String>("token"))

      updateFlutterState(SdkState.wait, multiVideoMethodChannel)
      initSession(apiKey, sessionId, token)
      result.success("")
    } else if (call.method == "endSession") {
      endSession()
    } else if (call.method == "enableCamera") {
      enableCamera()
    } else if (call.method == "disableCamera") {
      disableCamera()
    } else if (call.method == "enableMicrophone") {
      enableMicrophone()
    } else if (call.method == "disableMicrophone") {
      disableMicrophone()
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
  }

  private fun addFlutterChannelListener() {
    flutterEngine?.dartExecutor?.binaryMessenger?.let {
      setMultiVideoMethodChannel(it)
    }
  }
  private fun setMultiVideoMethodChannel(it: BinaryMessenger) {
    MethodChannel(it, multiVideoMethodChannel).setMethodCallHandler { call, result ->

      when (call.method) {
        "initSession" -> {
          val apiKey = requireNotNull(call.argument<String>("apiKey"))
          val sessionId = requireNotNull(call.argument<String>("sessionId"))
          val token = requireNotNull(call.argument<String>("token"))

          updateFlutterState(SdkState.wait, multiVideoMethodChannel)
          initSession(apiKey, sessionId, token)
          result.success("")
        }
        "endSession" -> {
          endSession()
        }
        else -> {
          result.notImplemented()
        }
      }
    }
  }

  fun updateFlutterState(state: SdkState, channel: String) {
    Handler(Looper.getMainLooper()).post {
      flutterEngine?.dartExecutor?.binaryMessenger?.let {
        MethodChannel(it, channel)
          .invokeMethod("updateState", state.toString())
      }
    }
  }

  fun updateSubscribers(subscriberLength: Int, channel: String) {
    Handler(Looper.getMainLooper()).post {
      flutterEngine?.dartExecutor?.binaryMessenger?.let {
        MethodChannel(it, channel)
          .invokeMethod("updateSubscribers", subscriberLength.toString())
      }
    }
  }

  fun updateFlutterMessages(arguments: HashMap<String, Any>, channel: String){
    Handler(Looper.getMainLooper()).post {
      flutterEngine?.dartExecutor?.binaryMessenger?.let {
        MethodChannel(it, channel)
          .invokeMethod("updateMessages", arguments)
      }
    }
  }

  fun updateFlutterArchiving(isArchiving: Boolean, channel: String){
    Handler(Looper.getMainLooper()).post {
      flutterEngine?.dartExecutor?.binaryMessenger?.let {
        MethodChannel(it, channel)
          .invokeMethod("updateArchiving", isArchiving)
      }
    }
  }


  private val sessionListener: Session.SessionListener = object : Session.SessionListener {
    override fun onConnected(session: Session) {
      // Connected to session
      Log.d("MainActivity", "Connected to session ${session.sessionId}")

      updateFlutterState(SdkState.loggedIn, multiVideoMethodChannel)
      session.publish(publisher)
    }

    override fun onDisconnected(session: Session) {
      updateFlutterState(SdkState.loggedOut, multiVideoMethodChannel)
    }

    override fun onStreamReceived(session: Session, stream: Stream) {
      Log.d(
        "MainActivity",
        "onStreamReceived: New Stream Received " + stream.streamId + " in session: " + session.sessionId
      )

      val subscriber = Subscriber.Builder(context, stream).build()
      session.subscribe(subscriber)
      subscribers.add(subscriber)
      subscriberStreams[stream] = subscriber
      val subId = getResIdForSubscriberIndex(subscribers.size - 1)
      subscriber.view.id = subId
      multiVideoPlatformView.mainContainer.addView(subscriber.view)
      updateSubscribers(subscribers.size, multiVideoMethodChannel);
      calculateLayout()
    }

    override fun onStreamDropped(session: Session, stream: Stream) {
      Log.d(
        "MainActivity",
        "onStreamDropped: Stream Dropped: " + stream.streamId + " in session: " + session.sessionId
      )
      val subscriber = subscriberStreams[stream] ?: return
      subscribers.remove(subscriber)
      subscriberStreams.remove(stream)
      multiVideoPlatformView.mainContainer.removeView(subscriber.view)

      // Recalculate view Ids
      for (i in subscribers.indices) {
        subscribers[i].view.id = getResIdForSubscriberIndex(i)
      }
      updateSubscribers(subscribers.size, multiVideoMethodChannel)
      calculateLayout()
    }

    override fun onError(session: Session, opentokError: OpentokError) {
      Log.d("MainActivity", "Session error: " + opentokError.message)
      updateFlutterState(SdkState.error, multiVideoMethodChannel)
    }
  }

  private val publisherListener: PublisherKit.PublisherListener = object :
    PublisherKit.PublisherListener {
    override fun onStreamCreated(publisherKit: PublisherKit, stream: Stream) {
      Log.d(
        "MainActivity",
        "onStreamCreated: Publisher Stream Created. Own stream " + stream.streamId
      )
    }

    override fun onStreamDestroyed(publisherKit: PublisherKit, stream: Stream) {
      Log.d(
        "MainActivity",
        "onStreamDestroyed: Publisher Stream Destroyed. Own stream " + stream.streamId
      )

      // Recalculate view Ids
      for (i in subscribers.indices) {
        multiVideoPlatformView.mainContainer.removeView(subscribers[i].view)
      }
      subscribers.clear()
      subscriberStreams.clear()
    }

    override fun onError(publisherKit: PublisherKit, opentokError: OpentokError) {
      Log.d("MainActivity", "PublisherKit onError: " + opentokError.message)
      updateFlutterState(SdkState.error, multiVideoMethodChannel)
    }
  }

  fun initSession(apiKey: String, sessionId: String, token: String) {
    session = Session.Builder(context, apiKey, sessionId).build()
    session?.setSessionListener(sessionListener)
    session?.connect(token)
    startPublisherPreview()
    publisher?.view?.id = R.id.publisher_view_id
    var multiVideo: PublisherView = publisherFactory.create(context,R.id.publisher_view_id, null)
    multiVideo.mainContainer.addView(publisher?.view)
//    multiVideoPlatformView.mainContainer.addView(publisher?.view)
//    calculateLayout()
  }

  fun endSession() {
    session?.unpublish(publisher)
    session?.disconnect()
  }

  fun disableMicrophone() {
    publisher?.setPublishAudio(false)
  }

  fun enableMicrophone() {
    publisher?.setPublishAudio(true)
  }

  fun disableCamera() {
    publisher?.setPublishVideo(false)
  }

  fun enableCamera() {
    publisher?.setPublishVideo(true)
  }

  private fun getResIdForSubscriberIndex(index: Int): Int {
    val arr = context!!.resources.obtainTypedArray(R.array.subscriber_view_ids)
    val subId = arr.getResourceId(index, 0)
    arr.recycle()
    return subId
  }

  private fun startPublisherPreview() {
    publisher = Publisher.Builder(context).build()
    publisher?.setPublisherListener(publisherListener)
    publisher?.setStyle(BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL)
  }
  private fun calculateLayout() {
    val set = ConstraintSetHelper(R.id.main_container)
    val size = subscribers.size
    if (size == 1) {
      // Publisher
      // Subscriber
      set.layoutViewFullScreen(getResIdForSubscriberIndex(0))
//      set.layoutViewAboveView(R.id.publisher_view_id, getResIdForSubscriberIndex(0))
//      set.layoutViewWithTopBound(R.id.publisher_view_id, R.id.main_container)
//      set.layoutViewWithBottomBound(getResIdForSubscriberIndex(0), R.id.main_container)
//      set.layoutViewAllContainerWide(R.id.publisher_view_id, R.id.main_container)
//      set.layoutViewAllContainerWide(getResIdForSubscriberIndex(0), R.id.main_container)
//      set.layoutViewHeightPercent(getResIdForSubscriberIndex(0), .5f)
    } else if (size > 1 && size % 2 == 0) {
      set.layoutViewAboveView(getResIdForSubscriberIndex(0), getResIdForSubscriberIndex(1))
      set.layoutViewWithTopBound(getResIdForSubscriberIndex(0), R.id.main_container)
      set.layoutViewWithBottomBound(getResIdForSubscriberIndex(1), R.id.main_container)
      set.layoutViewAllContainerWide(getResIdForSubscriberIndex(0), R.id.main_container)
      set.layoutViewAllContainerWide(getResIdForSubscriberIndex(1), R.id.main_container)
      set.layoutViewHeightPercent(getResIdForSubscriberIndex(0), .5f)
    }
    set.applyToLayout(multiVideoPlatformView.mainContainer, true)
  }
}
