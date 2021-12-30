import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubePlayScreen extends StatefulWidget {
  final String youtubeId;

  const YoutubePlayScreen({Key? key, required this.youtubeId})
      : super(key: key);

  @override
  _YoutubePlayScreenState createState() => _YoutubePlayScreenState();
}

///
class _YoutubePlayScreenState extends State<YoutubePlayScreen> {
  late YoutubePlayerController _controller;

  ///
  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.youtubeId,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        desktopMode: false,
        privacyEnhanced: true,
        useHybridComposition: true,
      ),
    );

    _controller.onEnterFullscreen = () {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    };

    _controller.onExitFullscreen = () {};
  }

  ///
  @override
  Widget build(BuildContext context) {
    const player = YoutubePlayerIFrame();

    return YoutubePlayerControllerProvider(
      controller: _controller,
      child: SafeArea(
        child: Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return (kIsWeb && constraints.maxWidth > 800) ? player : player;
            },
          ),
        ),
      ),
    );
  }

  ///
  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}
