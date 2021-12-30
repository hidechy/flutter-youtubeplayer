import 'package:http/http.dart';

import 'dart:convert';

class Logic {
  uploadBunruiItems({required String bunrui, required List bunruiItems}) async {
    Map<String, dynamic> _uploadData = {};
    _uploadData['bunrui'] = bunrui;
    _uploadData['youtube_id'] = bunruiItems.join(',');

    String url = "http://toyohide.work/BrainLog/api/bunruiYoutubeData";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode(_uploadData);
    await post(Uri.parse(url), headers: headers, body: body);
  }
}
