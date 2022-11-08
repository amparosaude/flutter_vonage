import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class Publisher extends StatelessWidget {
  static String _viewType = 'publisher-opentok-multi-video-container';
  int _pluginViewId = -1;

  Publisher({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> creationParams = <String, dynamic>{};
    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: _viewType,
        surfaceFactory: (BuildContext context,
            PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: _viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: StandardMessageCodec(),
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..create();
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: _viewType,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          _pluginViewId = id;
        },
      );
    }
    return Container();
  }
}