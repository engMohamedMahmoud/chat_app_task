import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class DisplayVoiceNoteWidget extends StatefulWidget {
  final String voiceMessage;
  const DisplayVoiceNoteWidget({super.key, required this.voiceMessage});

  @override
  State<DisplayVoiceNoteWidget> createState() => _DisplayVoiceNoteWidgetState();
}

class _DisplayVoiceNoteWidgetState extends State<DisplayVoiceNoteWidget> {

  final player = AudioPlayer();
  Duration? duration;

  void setAudioUrl({required String url}) async {
    try {
      await player.setUrl(url, initialPosition: Duration.zero);
      duration = await player.load();
    } on PlayerInterruptedException catch (e) {
      if (kDebugMode) {
        print("Exception $e");
      }
    }

  }

initSettings() {
   player.setAudioSource(AudioSource.uri(
  Uri.parse(widget.voiceMessage),
  )).then((value) {
    setState(() {
      duration = value;
    });
  },);

}

  @override
  void initState() {
  // initSettings();
  setAudioUrl(url: widget.voiceMessage);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(15),),
            child: Row(
              children: [
                StreamBuilder<PlayerState>(
                  stream: player.playerStateStream,
                  builder: (context, snapshot) {
                    if(snapshot.hasData){
                      final playerState = snapshot.data;
                      final processingState = playerState?.processingState;
                      var playing = playerState?.playing;
                      if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering || playing != true) {
                        return GestureDetector(
                          onTap: player.play,
                          child: const Icon(Icons.play_arrow, size: 30,),
                        );
                      }  else if (processingState != ProcessingState.completed) {
                        return GestureDetector(
                          onTap: player.pause,
                          child: const Icon(Icons.pause, size: 30,),
                        );
                      } else {
                        return GestureDetector(
                          child: const Icon(Icons.play_arrow,size: 30,),
                          onTap: () {

                            player.play();
                            player.seek(Duration.zero).then((value) async {
                              setState(() {
                                player.play();
                              });
                              // Delete the cached file
                            },);

                          },
                        );
                      }
                    }else{
                      return Container();
                    }
                  },
                ),


                const SizedBox(width: 8),
                Expanded(
                  child: StreamBuilder<Duration>(
                    stream: player.positionStream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            const SizedBox(height: 11),
                            LinearProgressIndicator(value: snapshot.data!.inMilliseconds / (duration?.inMilliseconds ?? 1),),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  prettyDuration(
                                      snapshot.data! == Duration.zero
                                          ? duration ?? Duration.zero
                                          : snapshot.data!),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    // color: Colors.white,
                                  ),
                                ),

                              ],
                            ),
                          ],
                        );
                      } else {
                        return const LinearProgressIndicator();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String prettyDuration(Duration d) {
    var min = d.inMinutes < 10 ? "0${d.inMinutes}" : d.inMinutes.toString();
    var sec = d.inSeconds < 10 ? "0${d.inSeconds}" : d.inSeconds.toString();
    return "$min:$sec";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    player.dispose();
    super.dispose();

  }
}
