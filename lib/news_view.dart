import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cnbeta/news_info.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

class NewsView extends StatefulWidget {
  final NewsInfo newsInfo;

  NewsView(this.newsInfo);

  @override
  State<StatefulWidget> createState() {
    return new _NewsViewState();
  }
}

class _NewsViewState extends State<NewsView> {
  var _articleBody;

  @override
  void initState() {
    super.initState();
    _fetchArticleBody().then((result) {
      setState(() {
        _articleBody = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.newsInfo.title),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    if (_articleBody == null) {
      return new Center(child: CircularProgressIndicator());
    }

    var _content = new Center(
      child: new Text(_articleBody),
    );

    return _content;
  }

  Future<String> _fetchArticleBody() async {
    final _url = 'https://m.cnbeta.com' + widget.newsInfo.url;

    // TODO: how to fetch js generated content: article-body, article-summary?
    try {
      print(_url);
      final response = await http.get(_url);
      if (response.statusCode == 200) {
        // var document = parse(response.body);
        // print(response.body);
        // print(document.toString());
        // var articleBody = document.getElementsByClassName('article-body');
        // print(articleBody);
        return widget.newsInfo.title;
      } else {
        throw Exception('failed to load news detail');
      }
    } catch (e) {
      print(e.toString());
    }

    return null;
  }
}
