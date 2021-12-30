import 'package:flutter/material.dart';

import 'package:http/http.dart';

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
                  onPressed: () => _goBunruiSettingScreen(bunrui: 'undefined'),
                  child: const Text('まだ分類されていない動画'),
                ),
              ),
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
  void _goHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
  }

  ///
  void _goBunruiSettingScreen({required String bunrui}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BunruiSettingScreen(bunrui: bunrui),
      ),
    );

    if (result!) {
      _goHomeScreen();
    }
  }

  ///
  void _goBunruiListScreen({required String bunrui}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BunruiListScreen(bunrui: bunrui),
      ),
    );
  }
}
