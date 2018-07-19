import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cnbeta/news_info.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter_html_view/flutter_html_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './utils.dart';

class NewsView extends StatefulWidget {
  final NewsInfo newsInfo;

  NewsView(this.newsInfo);

  @override
  State<StatefulWidget> createState() {
    return new _NewsViewState();
  }
}

class _NewsViewState extends State<NewsView> {
  List<String> _articleBody;
  bool _refreshInProgress = false;

  @override
  void initState() {
    super.initState();
    _getArticleBody().then((result) {
      setState(() {
        _refreshInProgress = false;
        _articleBody = result;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('cnBeta - ' + widget.newsInfo.label),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    var _content;

    List<Widget> _body = <Widget>[
      new Container(
        padding: new EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 3.0),
        child: new Text(
          normalizeTitle(widget.newsInfo.title),
          style: new TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      new Container(
          padding: new EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 3.0),
          child: new Row(
            children: <Widget>[
              new Row(
                children: <Widget>[
                  new Icon(Icons.timer),
                  new Text(widget.newsInfo.inputtime),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Icon(Icons.remove_red_eye),
                  new Text(widget.newsInfo.mview),
                ],
              ),
              new Row(
                children: <Widget>[
                  new Icon(Icons.send),
                  new Text(widget.newsInfo.source.split('@')[0]),
                ],
              ),
            ],
          )),
    ];

    if (_articleBody == null) {
      _content = new Center(child: CircularProgressIndicator());
    } else {
      _content = new Column(
        children: <Widget>[
          new Card(
            color: Colors.white10,
            margin: new EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
            child: new HtmlView(data: _articleBody[1]),
          ),
          new HtmlView(data: _articleBody[2]),
        ],
      );
    }

    _body.add(_content);

    var _refreshIndicator = new RefreshIndicator(
      onRefresh: _refreshData,
      child: new ListView(
        padding: new EdgeInsets.all(8.0),
        children: _body,
      ),
    );

    return _refreshIndicator;
  }

  Future<List<String>> _getArticleBody() async {
    List<String> _result;
    final _url = 'https://m.cnbeta.com' + widget.newsInfo.url;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _result = prefs.getStringList(widget.newsInfo.sid);
    // if (_refreshInProgress) _result = null;
    if (_result != null && !_refreshInProgress) {
      print('return state from shared preferences');
      return _result;
    }
    try {
      print(_url);
      final response = await http.get(_url);
      final document = parse(response.body);
      if (response.statusCode == 200) {
        String summary = document
            .getElementsByClassName('article-summary')[0]
            .innerHtml
            .replaceAll('<b>摘要：</b>', '');
        // print('summary: $summary');
        // TODO: data-* attributes are not supported by flutter_html_view
        // https://github.com/PonnamKarthik/FlutterHtmlView/issues/13
        String body = document
            .getElementsByClassName('article-body')[0]
            .innerHtml
            .replaceAll(new RegExp('data-[a-z]+="[^\"]+"'), '');
        // print('body: $body');
        _result = <String>['success', summary, body];
        await prefs.setStringList(widget.newsInfo.sid, _result);
        return _result;
      } else {
        throw Exception('failed to load news detail');
      }
    } catch (e) {
      print(e.toString());
    }

    return null;
  }

  Future<Null> _refreshData() async {
    print('refresh data');
    _refreshInProgress = true;
    _getArticleBody().then((result) {
      setState(() {
        _articleBody = result;
      });
    });
  }
}
