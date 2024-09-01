import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

class CrossfadeManager {
  final AudioPlayer audioPlayer;
  final List<AudioSource> audioSources;
  int currentIndex;
  Duration crossfadeDuration;
  Timer? _crossfadeTimer;
  VoidCallback? onTrackChanged;

  CrossfadeManager({
    required this.audioPlayer,
    required this.audioSources,
    required this.currentIndex,
    required this.crossfadeDuration,
    this.onTrackChanged,
  });

  void startCrossfade(Duration currentPosition, Duration totalDuration) {
    _crossfadeTimer?.cancel();

    if (crossfadeDuration > Duration.zero && totalDuration > Duration.zero) {
      final crossfadeStart = totalDuration - crossfadeDuration;

      if (currentPosition >= crossfadeStart && currentPosition < totalDuration) {
        _crossfadeTimer = Timer.periodic(
          Duration(milliseconds: 100),
              (timer) {
            if (audioPlayer.position >= crossfadeStart) {
              performCrossfade();
              timer.cancel();
            }
          },
        );
      }
    }
  }

  Future<void> performCrossfade() async {
    if (crossfadeDuration > Duration.zero) {
      double currentVolume = audioPlayer.volume;
      int fadeSteps = 10;
      int fadeStepDuration = (crossfadeDuration.inMilliseconds / fadeSteps).round();

      // Fading out la traccia corrente
      for (int i = fadeSteps; i >= 0; i--) {
        double volumeStep = currentVolume * (i / fadeSteps);
        audioPlayer.setVolume(volumeStep.clamp(0.0, 1.0));
        await Future.delayed(Duration(milliseconds: fadeStepDuration));
      }

      // Cambia traccia
      await audioPlayer.stop();
      playNext();

      // Fading in la nuova traccia
      for (int i = 0; i <= fadeSteps; i++) {
        double volumeStep = currentVolume * (i / fadeSteps);
        audioPlayer.setVolume(volumeStep.clamp(0.0, 1.0));
        await Future.delayed(Duration(milliseconds: fadeStepDuration));
      }
    } else {
      playNext();
    }
  }


  Future<void> playTrack(int index) async {
    if (index < 0 || index >= audioSources.length) return;
    currentIndex = index;
    await audioPlayer.setAudioSource(audioSources[currentIndex]);
    audioPlayer.play();
    onTrackChanged?.call();
  }

  void playNext() async {
    print('Playing next track');

    if (currentIndex < audioSources.length - 1) {
      currentIndex++;
    } else {
      currentIndex = 0;
    }

    print('Next track index: $currentIndex, Title: ${(audioSources[currentIndex] as UriAudioSource).uri.toString()}');

    await audioPlayer.setAudioSource(audioSources[currentIndex]);
    audioPlayer.play();
    onTrackChanged?.call();
  }

  void updateCrossfadeDuration(Duration newDuration) {
    crossfadeDuration = newDuration;
  }

  void dispose() {
    _crossfadeTimer?.cancel();
  }
}