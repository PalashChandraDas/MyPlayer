import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late Size size;
  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;
  late PlayerState _playerState;
  double _volume = 100;
  bool _muted = false;
  bool _isPlayerReady = false;

  final List<String> _ids = [
    'Gvi4uUj9o18',
    'hbXuXt7gkFY',
    'bvM6fsdARxw',
    'lR2467u2gNE',
    '7F6GaoZo8iY',
    'hYZaC780XFE',
  ];
  //using VIDEO URL
  late String videoId;

  @override
  void initState() {
    super.initState();

    videoId = YoutubePlayer.convertUrlToId(
        'https://www.youtube.com/watch?v=cOHFhUYeal4')!;

    _controller = YoutubePlayerController(
        // initialVideoId: _ids.first,
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          playbackQuality: [144, 240, 360, 480, 720, 1080],
          mute: false,
          autoPlay: true,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: true,
        ))
      ..addListener(listener);

    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _playerState = PlayerState.unknown;
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _playerState = _controller.value.playerState;
      });
    }
  }

  //let's handle on deactivate and dispose
  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return YoutubePlayerBuilder(
      onEnterFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      },

      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        showVideoProgressIndicator: true,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.white,
          backgroundColor: Colors.black38,
          // bufferedColor: Colors.red,
        ),
        controller: _controller,
        topActions: [
          const SizedBox(
            width: 8.0,
          ),
          Expanded(
              child: Text(
            _controller.metadata.title,
            style: const TextStyle(color: Colors.white, fontSize: 16.0),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          )),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (metaData) {
          _controller
              .load(_ids[(_ids.indexOf(metaData.videoId) + 1) % _ids.length]);
        },
      ),
      //let's set the player on screen

      builder: (context, player) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/app_icon.png',
                height: 40.0,
                width: 40.0,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  'Mytube',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          height: size.height,
          width: size.width,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Center(
            child: ListView(
              shrinkWrap: true,
              children: [
                player,

                //let's add next, prev and pause button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            //onPressed: using Ternary_Operator
                            onPressed: _isPlayerReady
                                ? () => _controller.load(_ids[(_ids.indexOf(
                                            _controller.metadata.videoId) -
                                        1) %
                                    _ids.length])
                                : null,
                            icon: const Icon(Icons.skip_previous),
                            color: Colors.white,
                          ),
                          IconButton(
                            //onPressed: using Ternary_Operator
                            onPressed: _isPlayerReady
                                ? () {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  }
                                : null,
                            icon: Icon(_controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow),
                            color: Colors.white,
                          ),
                          IconButton(
                            //onPressed: using Ternary_Operator
                            onPressed: _isPlayerReady
                                ? () => _controller.load(_ids[(_ids.indexOf(
                                            _controller.metadata.videoId) +
                                        1) %
                                    _ids.length])
                                : null,
                            icon: const Icon(Icons.skip_next),
                            color: Colors.white,
                          ),

                          //Add a FULLSCREEN button
                          FullScreenButton(
                            controller: _controller,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      //let's add a volume button and slider
                      _space,
                      Row(
                        children: [
                          IconButton(
                            //onPressed: using Ternary_Operator
                            onPressed: _isPlayerReady
                                ? () {
                                    _muted
                                        ? _controller.unMute()
                                        : _controller.mute();

                                    setState(() {
                                      _muted = !_muted;
                                    });
                                  }
                                : null,
                            icon: Icon(
                                _muted ? Icons.volume_off : Icons.volume_up),
                            color: Colors.white,
                          ),
                          Expanded(
                            child: CupertinoSlider(
                              activeColor: Colors.red,
                              thumbColor: Colors.yellow,
                              value: _volume,
                              min: 0.0,
                              max: 100.0,
                              onChanged: _isPlayerReady
                                  ? (value) {
                                      setState(() {
                                        _volume = value;
                                      });
                                      _controller.setVolume(_volume.round());
                                    }
                                  : null,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget get _space => const SizedBox(
        height: 15,
      );
}
