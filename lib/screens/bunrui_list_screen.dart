import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher.dart';

//import 'package:youtubeplayer/screens/youtube_play_screen.dart';

import 'dart:convert';

import '../model/youtube_data.dart';

import '../utilities/utility.dart';

import '../logic/logic.dart';

class BunruiListScreen extends StatefulWidget {
  final String bunrui;

  const BunruiListScreen({Key? key, required this.bunrui}) : super(key: key);

  @override
  _BunruiListScreenState createState() => _BunruiListScreenState();
}

class _BunruiListScreenState extends State<BunruiListScreen> {
  final Utility _utility = Utility();
  final _logic = Logic();

  List<Video> _youtube = [];

  final List<String> _selectedList = [];

  final List<String> _specialList = [];

  /// 初期動作
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /// 初期データ作成
  void _makeDefaultDisplayData() async {
    ////////////////////////////////////////
    String url = "http://toyohide.work/BrainLog/api/getYoutubeList";
    Map<String, String> headers = {'content-type': 'application/json'};

    String body = '';
    switch (widget.bunrui) {
      case 'all':
        body = json.encode({"bunrui": ''});
        break;

      default:
        body = json.encode({"bunrui": widget.bunrui});
        break;
    }

    Response response =
        await post(Uri.parse(url), headers: headers, body: body);

    final youtubeData = youtubeDataFromJson(response.body);
    _youtube = youtubeData.data;
    ////////////////////////////////////////

    for (var element in _youtube) {
      if (element.special == '1') {
        _specialList.add(element.youtubeId);
      }
    }

    setState(() {});
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bunrui),
        backgroundColor: Colors.redAccent.withOpacity(0.3),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _utility.getBackGround(context: context),
          Column(
            children: [
              Expanded(child: _movieList()),
              const Divider(
                color: Colors.redAccent,
                thickness: 3,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.redAccent.withOpacity(0.3),
                        ),
                        onPressed: () => _uploadSpecialItems(),
                        child: const Text('選出変更'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.redAccent.withOpacity(0.3),
                        ),
                        onPressed: () => _uploadEraseItems(),
                        child: const Text('分類消去'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.redAccent.withOpacity(0.3),
                        ),
                        onPressed: () => _uploadDeleteItems(),
                        child: const Text('削除'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  Widget _movieList() {
    return ListView.separated(
      itemCount: _youtube.length,
      itemBuilder: (context, int position) => _listItem(position: position),
      separatorBuilder: (BuildContext context, int index) {
        return const Divider(color: Colors.white);
      },
    );
  }

  /// リストアイテム表示
  Widget _listItem({required int position}) {
    var date = _youtube[position].getdate;
    var year = date.substring(0, 4);
    var month = date.substring(4, 6);
    var day = date.substring(6);

    return Card(
      color: _getSelectedBgColor(youtubeId: _youtube[position].youtubeId),
      child: ListTile(
        title: DefaultTextStyle(
          style: const TextStyle(fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => _addSelectedAry(
                        youtubeId: _youtube[position].youtubeId),
                    child: const Icon(
                      Icons.control_point,
                      color: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          width: 180,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          child: FadeInImage.assetNetwork(
                            placeholder: 'assets/images/no_image.png',
                            image:
                                'https://img.youtube.com/vi/${_youtube[position].youtubeId}/mqdefault.jpg',
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 140,
                            color: Colors.black.withOpacity(0.5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_youtube[position].title),
                                const SizedBox(height: 5),
                                Text(
                                    '${_youtube[position].youtubeId} / $year/$month/$day'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: (_youtube[position].special == '1')
                        ? const Icon(
                            Icons.star,
                            color: Colors.greenAccent,
                          )
                        : Icon(
                            Icons.check_box_outline_blank,
                            color: Colors.black.withOpacity(0.2),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),

        trailing: GestureDetector(
          onTap: () => _openBrowser(youtubeId: _youtube[position].youtubeId),
          child: const Icon(Icons.link),
        ),

        //
        // trailing: GestureDetector(
        //   onTap: () =>
        //       _goYoutubePlayScreen(youtubeId: _youtube[position].youtubeId),
        //   child: const Icon(
        //     Icons.movie_creation_outlined,
        //     color: Colors.white,
        //   ),
        // ),
        //
      ),
    );
  }

  ///
  void _addSelectedAry({youtubeId}) {
    if (_selectedList.contains(youtubeId)) {
      _selectedList.remove(youtubeId);
    } else {
      _selectedList.add(youtubeId);
    }

    setState(() {});
  }

  ///
  Color _getSelectedBgColor({youtubeId}) {
    if (_selectedList.contains(youtubeId)) {
      return Colors.greenAccent.withOpacity(0.3);
    } else {
      return Colors.black.withOpacity(0.1);
    }
  }

  ///
  void _uploadDeleteItems() async {
    if (_selectedList.isNotEmpty) {
      var _list = [];
      for (var element in _selectedList) {
        _list.add("'$element'");
      }

      await _logic.uploadBunruiItems(
        bunrui: 'delete',
        bunruiItems: _list,
      );
    }

    _goBunruiListScreen();
  }

  ///
  void _uploadEraseItems() async {
    if (_selectedList.isNotEmpty) {
      var _list = [];
      for (var element in _selectedList) {
        _list.add("'$element'");
      }

      await _logic.uploadBunruiItems(
        bunrui: 'erase',
        bunruiItems: _list,
      );
    }

    _goBunruiListScreen();
  }

  ///
  void _openBrowser({required String youtubeId}) async {
    var url = 'https://youtu.be/$youtubeId';

    if (await canLaunch(url)) {
      await launch(url);
    } else {}
  }

  ///
  void _uploadSpecialItems() async {
    if (_selectedList.isNotEmpty) {
      var _list = [];
      for (var element in _selectedList) {
        var sp = (_specialList.contains(element)) ? 0 : 1;

        _list.add("$element|$sp");
      }

      await _logic.uploadBunruiItems(
        bunrui: 'special',
        bunruiItems: _list,
      );
    }

    _goBunruiListScreen();
  }

  ///////////////////////////////////////////////////////

  void _goBunruiListScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BunruiListScreen(
          bunrui: widget.bunrui,
        ),
      ),
    );
  }

//
  // void _goYoutubePlayScreen({required String youtubeId}) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => YoutubePlayScreen(youtubeId: youtubeId),
  //     ),
  //   );
  // }
  //

}
