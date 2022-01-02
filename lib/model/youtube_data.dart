// To parse this JSON data, do
//
//     final youtubeData = youtubeDataFromJson(jsonString);

import 'dart:convert';

YoutubeData youtubeDataFromJson(String str) =>
    YoutubeData.fromJson(json.decode(str));

String youtubeDataToJson(YoutubeData data) => json.encode(data.toJson());

class YoutubeData {
  YoutubeData({
    required this.data,
  });

  List<Video> data;

  factory YoutubeData.fromJson(Map<String, dynamic> json) => YoutubeData(
        data: List<Video>.from(json["data"].map((x) => Video.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Video {
  Video(
      {required this.youtubeId,
      required this.title,
      required this.getdate,
      required this.url,
      this.bunrui,
      this.special});

  String youtubeId;
  String title;
  String getdate;
  String url;
  dynamic bunrui;
  dynamic special;

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        youtubeId: json["youtube_id"],
        title: json["title"],
        getdate: json["getdate"],
        url: json["url"],
        bunrui: json["bunrui"],
        special: json["special"],
      );

  Map<String, dynamic> toJson() => {
        "youtube_id": youtubeId,
        "title": title,
        "getdate": getdate,
        "url": url,
        "bunrui": bunrui,
        "special": special,
      };
}
