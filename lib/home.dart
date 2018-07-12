import 'dart:async';
import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cnbeta/news_info.dart';
import 'package:cnbeta/news_view.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomeState();
  }
}

class _HomeState extends State<Home> {
  List<NewsInfo> _newsList = new List<NewsInfo>();
  int _page = 1;
  String _baseUrl = 'https://m.cnbeta.com/touch/default/timeline.json';
  bool _updateInProgress = false;
  bool _loadNextPage = false;
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
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
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('cnBeta 资讯'),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(context),
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return new FloatingActionButton(
      child: _updateInProgress
          ? new CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation(Colors.white),
            )
          : new Icon(Icons.update, size: 40.0),
      onPressed: () {
        print(DateTime.now().toString() + ': floating action button pressed');
        _page = 1;
        setState(() {
          _updateInProgress = true;
        });
        _scrollController.animateTo(
          0.0,
          duration: new Duration(milliseconds: 500),
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

  Widget _buildBody(BuildContext context) {
    var content;

    if (_newsList.isEmpty) {
      content = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      content = ListView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: _newsList.length,
        itemBuilder: (context, i) {
          // print('builder index: $i');
          if (i.isOdd) {
            return new Divider();
          }
          final index = i ~/ 2;
          var news = _newsList[index];
          return new ListTile(
            title: news.title.startsWith('<')
                ? new Text(
                    news.title.replaceAll(new RegExp('</span>|<span.*">'), ''),
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold))
                : new Text(news.title),
            subtitle: new Text(news.label + ' | ' + news.inputtime),
            trailing: new Container(
              width: 50.0,
              height: 50.0,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(color: Colors.grey, width: 2.0),
                image: new DecorationImage(
                  image: new NetworkImage(news.thumb),
                  // image: new CachedNetworkImageProvider(news.thumb),
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                new MaterialPageRoute(
                  builder: (context) => new NewsView(news),
                ),
              );
            },
          );
        },
      );
    }

    var _refreshIndicator = new RefreshIndicator(
      onRefresh: _loadLatest,
      child: content,
    );

    return _refreshIndicator;
  }

  Future<List<NewsInfo>> _getNewsList() async {
    List<NewsInfo> _result = new List<NewsInfo>();
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
