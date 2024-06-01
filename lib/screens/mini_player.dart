import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';

class MiniPlayer extends StatelessWidget {
  final AudioPlayer audioPlayer;

  const MiniPlayer({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sequenceState = Provider.of<SequenceState?>(context);
    final currentSource = sequenceState?.currentSource;

    if (currentSource == null) {
      return SizedBox.shrink();
    }

    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(audioPlayer.playing ? Icons.pause : Icons.play_arrow),
            onPressed: () {
              if (audioPlayer.playing) {
                audioPlayer.pause();
              } else {
                audioPlayer.play();
              }
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentSource.tag?.title ?? 'Unknown Title',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  currentSource.tag?.artist ?? 'Unknown Artist',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.skip_next),
            onPressed: audioPlayer.hasNext ? audioPlayer.seekToNext : null,
          ),
        ],
      ),
    );
  }
}
