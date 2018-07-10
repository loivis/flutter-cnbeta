import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cnbeta/news.dart';
import 'package:cnbeta/news_detail.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomeState();
  }
}

class _HomeState extends State<Home> {
  List<News> _newsList = new List<News>();
  int _page = 1;
  String _url = 'https://m.cnbeta.com/touch/default/timeline.json';

  @override
  void initState() {
    super.initState();
    _fetchNewsList().then((result) {
      setState(() {
        _newsList = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('cnBeta 资讯'),
      ),
      body: _buildBody(context),
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
        itemBuilder: (context, i) {
          print('builder index: $i');
          if (i.isOdd) {
            return new Divider();
          }
          final index = i ~/ 2;
          print('news index: $index');
          print('news length: ' + _newsList.length.toString());
          if (index + 20 >= _newsList.length) {
            _fetchNewsList();
          }
          var news = _newsList[index];
          return new ListTile(
            title: new Text(news.title),
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
                  builder: (context) => new NewsDetail(news),
                ),
              );
            },
          );
        },
      );
    }

    return content;
  }

  Future<List<News>> _fetchNewsList() async {
    if (_page != 1) {
      _url += '?page=' + _page.toString();
    }
    print(_url);
    _page++;

    try {
      final response = await http.get(_url);
      if (response.statusCode == 200) {
        for (var item in json.decode(response.body)['result']['list']) {
          _newsList.add(News.fromJson(item));
        }
        return _newsList;
      } else {
        throw Exception('Failed to load news');
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }
}
