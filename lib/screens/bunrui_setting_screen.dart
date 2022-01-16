import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

import 'dart:convert';

import '../model/youtube_data.dart';
import '../model/draggable_list.dart';

import '../logic/logic.dart';

import '../utilities/utility.dart';
import 'home_screen.dart';

class BunruiSettingScreen extends StatefulWidget {
  final String bunrui;

  const BunruiSettingScreen({Key? key, required this.bunrui}) : super(key: key);

  ///
  @override
  _BunruiSettingScreenState createState() => _BunruiSettingScreenState();
}

class _BunruiSettingScreenState extends State<BunruiSettingScreen> {
  final Utility _utility = Utility();
  final _logic = Logic();

  List<Video> _youtube = [];

  List<DragAndDropList> lists = [];

  RegExp reg = RegExp("Text(.+)");

  List<String> bunruiItems = [];

  TextEditingController bunruiText = TextEditingController();

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
      case 'undefined':
        body = json.encode({"bunrui": 'blank'});
        break;

      case 'delete':
        body = json.encode({"bunrui": ''});
        bunruiText.text = 'delete';
        break;
    }

    Response response =
        await post(Uri.parse(url), headers: headers, body: body);

    final youtubeData = youtubeDataFromJson(response.body);
    _youtube = youtubeData.data;
    ////////////////////////////////////////

    List<DraggableListItem> _list = [];
    for (var element in _youtube) {
      var _text = '${element.title} // ${element.youtubeId}';

      _list.add(DraggableListItem(title: _text));
    }

    ///
    List<DraggableList> allLists = [
      const DraggableList(
        header: 'LIST_UP',
        items: [DraggableListItem(title: '-----')],
      ),
      DraggableList(
        header: 'ALL',
        items: _list,
      ),
    ];

    lists = allLists.map(buildList).toList();

    setState(() {});
  }

  ///
  DragAndDropList buildList(DraggableList list) {
    return DragAndDropList(
      ///
      header: Text(list.header),

      ///
      children: list.items.map(
        (item) {
          return DragAndDropItem(
            child: Text(item.title),
          );
        },
      ).toList(),
    );
  }

  ///
  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.white.withOpacity(0.3);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bunrui),
        backgroundColor: Colors.redAccent.withOpacity(0.3),
        centerTitle: true,

        //-------------------------//これを消すと「←」が出てくる（消さない）
        leading: const Icon(
          Icons.check_box_outline_blank,
          color: Color(0xFF2e2e2e),
        ),
        //-------------------------//これを消すと「←」が出てくる（消さない）

        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _goHomeScreen(),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _utility.getBackGround(context: context),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: bunruiText,
                      decoration: const InputDecoration(labelText: '分類'),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent.withOpacity(0.3),
                      ),
                      onPressed: () => _dispBunruiItem(),
                      child: const Text('分類する'),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: DragAndDropLists(
                  children: lists,

                  ///
                  listPadding: const EdgeInsets.all(16),

                  ///
                  onItemReorder: onReorderListItem,
                  onListReorder: onReorderList,

                  ///
                  itemDivider: Divider(
                    thickness: 2,
                    height: 2,
                    color: backgroundColor,
                  ),

                  ///
                  itemDecorationWhileDragging: const BoxDecoration(
                    color: Colors.blueGrey,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        blurRadius: 4,
                      ),
                    ],
                  ),

                  ///
                  lastListTargetSize: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ///
  void onReorderListItem(
    int oldItemIndex,
    int oldListIndex,
    int newItemIndex,
    int newListIndex,
  ) {
    setState(
      () {
        final oldListItems = lists[oldListIndex].children;
        final newListItems = lists[newListIndex].children;

        final movedItem = oldListItems.removeAt(oldItemIndex);
        newListItems.insert(newItemIndex, movedItem);
      },
    );
  }

  ///
  void onReorderList(
    int oldListIndex,
    int newListIndex,
  ) {}

  ///
  void _dispBunruiItem() async {
    bunruiItems = [];

    for (var value in lists) {
      var listName = '';
      var match = reg.firstMatch(value.header.toString());
      if (match != null) {
        listName = match
            .group(1)!
            .replaceAll('(', '')
            .replaceAll(')', '')
            .replaceAll('"', '');
      }

      if (listName == "LIST_UP") {
        for (var child in value.children) {
          var match2 = reg.firstMatch(child.child.toString());
          if (match2 != null) {
            var item = match2
                .group(1)!
                .replaceAll('(', '')
                .replaceAll(')', '')
                .replaceAll('"', '');

            if (item != "-----") {
              var exItem = (item).split(' // ');
              bunruiItems.add("'${exItem[1]}'");
            }
          }
        }
      }
    }

    if (bunruiItems.isNotEmpty) {
      _logic.uploadBunruiItems(
        bunrui: bunruiText.text,
        bunruiItems: bunruiItems,
      );
    }

    await Future.delayed(const Duration(seconds: 3));

    _goHomeScreen();
  }

  /////////////////////////////////////////////////////

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
