import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cnbeta/news_info.dart';
import 'package:cnbeta/news_view.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as locale;
import './utils.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  List<NewsInfo> _newsList = List<NewsInfo>();
  int _page = 1;
  String _baseUrl = 'https://m.cnbeta.com/touch/default/timeline.json';
  bool _updateInProgress = false;
  bool _loadNextPage = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    locale.initializeDateFormatting();
    _scrollController.addListener(_scrollListener);
    _loadLatest();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('cnBeta 资讯'),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    var _content;

    if (_newsList.isEmpty) {
      _content = Center(
        child: CircularProgressIndicator(),
      );
    } else {
      _content = ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: _newsList.length * 2,
        itemBuilder: _buildListViewItem,
      );
    }

    var _refreshIndicator = RefreshIndicator(
      onRefresh: _loadLatest,
      child: _content,
    );

    return _refreshIndicator;
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      child: _updateInProgress
          ? CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            )
          : Icon(Icons.update, size: 40.0),
      onPressed: () {
        print(DateTime.now().toString() + ': floating action button pressed');
        _page = 1;
        setState(() {
          _updateInProgress = true;
        });
        _scrollController.animateTo(
          0.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.linear,
        );
        _getNewsList().then((result) {
          setState(() {
            _newsList = result;
            _updateInProgress = false;
          });
        });
      },
    );
  }

  Widget _buildListViewItem(BuildContext context, int index) {
    // print('builder index: $i');
    var newsIndex = index ~/ 2;
    var news = _newsList[newsIndex];
    var _newsSpliter = Container(
      child: Row(
        children: <Widget>[
          Icon(Icons.today),
          Text(_getNewsDate(news)),
        ],
      ),
      decoration: BoxDecoration(color: Colors.black26),
    );
    if (index == 0) {
      return _newsSpliter;
    }
    if (index.isEven) {
      if (news.inputtime.split(' ')[0] !=
          _newsList[newsIndex - 1].inputtime.split(' ')[0]) {
        return _newsSpliter;
      }
      return Divider();
    }
    return ListTile(
      title: news.title.startsWith('<')
          ? Text(
              normalizeTitle(news.title),
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            )
          : Text(news.title),
      // subtitle: Text(news.label + ' | ' + news.inputtime),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(news.label + ' | ' + news.inputtime),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(news.good),
              Icon(Icons.thumbs_up_down, color: Colors.grey),
              Text(news.bad),
            ],
          ),
        ],
      ),
      trailing: Container(
        width: 50.0,
        height: 50.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2.0),
          image: DecorationImage(
            image: CachedNetworkImageProvider(news.thumb),
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsView(news),
          ),
        );
      },
    );
  }

  Future<List<NewsInfo>> _getNewsList() async {
    List<NewsInfo> _result = List<NewsInfo>();
    var _url;

    print(DateTime.now().toString());
    print('news length: ' + _newsList.length.toString());

    if (_page == 1) {
      _url = _baseUrl;
    } else {
      _url = _baseUrl + '?page=' + _page.toString();
    }
    print(_url);
    _page++;

    try {
      _loadNextPage = true;
      final response = await http.get(_url);
      _loadNextPage = false;
      if (response.statusCode == 200) {
        for (var item in json.decode(response.body)['result']['list']) {
          _result.add(NewsInfo.fromJson(item));
        }
        return _result;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print(e.toString());
    }

    return null;
  }

  Future<Null> _loadLatest() async {
    _page = 1;
    var result = await _getNewsList();

    setState(() {
      _newsList = result;
    });
  }

  void _scrollListener() {
    // print(_scrollController.position.extentAfter);
    if (_scrollController.position.extentAfter < 888 && !_loadNextPage) {
      print('over scroll loading');
      _getNewsList().then((result) {
        setState(() {
          _newsList.addAll(result);
        });
      });
    }
  }
}

String _getNewsDate(NewsInfo news) {
  var _inputtime = news.inputtime.split(' ')[0].split('-');
  var _year = int.parse(_inputtime[0]);
  var _month = int.parse(_inputtime[1]);
  var _day = int.parse(_inputtime[2]);
  var _date = DateTime(_year, _month, _day);
  var _formatter = DateFormat('yyyy-MM-dd EEEE', 'zh_CN');
  return _formatter.format(_date);
}
