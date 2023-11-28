import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_controller/volume_controller.dart';

class AudioController extends GetxController {
  AudioPlayer player    = AudioPlayer();
  String alert1         = "audio/1_接続成功音.mp3";
  String alert2         = "audio/2_BT切断.mp3";

  @override
  void onInit() {
    VolumeController().showSystemUI = false;
    player.setReleaseMode(ReleaseMode.stop);
    super.onInit();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  warningSound1(bool playAlert1Flag,bool loop) async {
    VolumeController().showSystemUI = false;
    VolumeController().setVolume(0.1);
    if (playAlert1Flag) {
      // Play the sound initially
      await player.play(AssetSource(alert1)).then(
        (value) => 
        // If play was successful, set the release mode based on the loop parameter
        loop ? player.setReleaseMode(ReleaseMode.loop) : player.setReleaseMode(ReleaseMode.stop)
      );
    } else {
      // Stop the audio if playWarning1Flag is false
      await player.stop();
    }
  }

  warningSound2(bool playAlert2Flag,bool loop) async {
    VolumeController().showSystemUI = false;
    VolumeController().setVolume(0.1);
    if(playAlert2Flag) {
      // Play the sound initially
      await player.play(AssetSource(alert2)).then(
        (value) => 
        // If play was successful, set the release mode based on the loop parameter
        loop ? player.setReleaseMode(ReleaseMode.loop) : player.setReleaseMode(ReleaseMode.stop)
      );
    } else {
      // Stop the audio if playWarning1Flag is false
      await player.stop();
    }
  }
}
