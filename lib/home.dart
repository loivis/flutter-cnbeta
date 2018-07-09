import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:cnbeta/news_item.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new _HomeState();
  }
}

class _HomeState extends State<Home> {
  List<NewsItem> _newsList = new List<NewsItem>();
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchNews().then((result) {
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
            _fetchNews();
          }
          return new ListTile(
            title: new Text(_newsList[index].title),
            subtitle: new Text(
                _newsList[index].label + ' | ' + _newsList[index].inputtime),
            trailing: new Container(
              width: 50.0,
              height: 50.0,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                image: new DecorationImage(
                  image: new NetworkImage(_newsList[index].thumb),
                  // image: new CachedNetworkImageProvider(_newsList[index].thumb),
                ),
              ),
            ),
          );
        },
      );
    }

    return content;
  }

  Future<List<NewsItem>> _fetchNews() async {
    String url = 'https://m.cnbeta.com/touch/default/timeline.json';
    if (_page != 1) {
      url += '?page=' + _page.toString();
    }
    print(url);
    _page++;

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        for (var item in json.decode(response.body)['result']['list']) {
          _newsList.add(NewsItem.fromJson(item));
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
