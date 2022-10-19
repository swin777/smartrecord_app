import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class PlayData {
  double? startLat;
  double? startLng;
  double? endLat;
  double? endLng;
  PlayData({
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
  });
}