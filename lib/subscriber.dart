import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class Subscriber extends StatelessWidget {
  static String _viewType = 'opentok-multi-video-container';
  int _pluginViewId = -1;

  Subscriber({ Key key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PlatformViewLink(
      viewType: 'opentok-multi-video-container',
      surfaceFactory:
          (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (PlatformViewCreationParams params) {
        return PlatformViewsService.initSurfaceAndroidView(
          id: params.id,
          viewType: 'opentok-multi-video-container',
          layoutDirection: TextDirection.ltr,
          creationParams: {},
          creationParamsCodec: const StandardMessageCodec(),
          onFocus: () {
            params.onFocusChanged(true);
          },
        )
          ..addOnPlatformViewCreatedListener(
              params.onPlatformViewCreated)
          ..create();
      },
    );
  }
}