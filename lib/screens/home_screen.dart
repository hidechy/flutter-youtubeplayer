import 'package:flutter/material.dart';

import 'package:http/http.dart';
import 'package:youtubeplayer/model/youtube_data.dart';

import 'dart:convert';

import '../utilities/utility.dart';

import 'bunrui_setting_screen.dart';
import 'bunrui_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Utility _utility = Utility();

  final List<String> _bunruiList = [];

  bool _blankExists = false;

  /// 初期動作
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /// 初期データ作成
  void _makeDefaultDisplayData() async {
    ////////////////////////////////////////
    String url = "http://toyohide.work/BrainLog/api/getBunruiName";
    Map<String, String> headers = {'content-type': 'application/json'};
    Response response = await post(Uri.parse(url), headers: headers);
    var data = jsonDecode(response.body);
    for (var i = 0; i < data['data'].length; i++) {
      _bunruiList.add(data['data'][i]);
    }
    ////////////////////////////////////////
    ////////////////////////////////////////
    String url2 = "http://toyohide.work/BrainLog/api/getYoutubeList";
    Map<String, String> headers2 = {'content-type': 'application/json'};
    String body2 = json.encode({"bunrui": 'blank'});
    Response response2 =
        await post(Uri.parse(url2), headers: headers2, body: body2);
    final youtubeData = youtubeDataFromJson(response2.body);
    if (youtubeData.data.isNotEmpty) {
      _blankExists = true;
    }
    ////////////////////////////////////////

    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Category'),
        backgroundColor: Colors.redAccent.withOpacity(0.3),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _goHomeScreen(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _utility.getBackGround(context: context),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _bunruiButtonList(),
              ),
              (_blankExists)
                  ? Column(
                      children: [
                        const Divider(
                          color: Colors.redAccent,
                          thickness: 3,
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(10),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.redAccent.withOpacity(0.3),
                            ),
                            onPressed: () =>
                                _goBunruiSettingScreen(bunrui: 'undefined'),
                            child: const Text('分類する'),
                          ),
                        ),
                      ],
                    )
                  : Container()
            ],
          ),
        ],
      ),
    );
  }

  ///
  Widget _bunruiButtonList() {
    if (_bunruiList.isEmpty) {
      return Container();
    }

    List<Widget> _list = [];

    for (var element in _bunruiList) {
      _list.add(
        Card(
          color: Colors.black.withOpacity(0.1),
          child: ListTile(
            onTap: () => _goBunruiListScreen(bunrui: element),
            title: Text(element),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _list,
      ),
    );
  }

  /////////////////////////////////////

  ///
  void _goBunruiSettingScreen({required String bunrui}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BunruiSettingScreen(bunrui: bunrui),
      ),
    );
  }

  ///
  void _goBunruiListScreen({required String bunrui}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BunruiListScreen(bunrui: bunrui),
      ),
    );
  }

  ///
  void _goHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }
}
