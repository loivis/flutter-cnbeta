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
    return _NewsViewState();
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
    return Scaffold(
      appBar: AppBar(
        title: Text('cnBeta - ' + widget.newsInfo.label),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    var _content;

    List<Widget> _body = <Widget>[
      Container(
        padding: EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 3.0),
        child: Text(
          normalizeTitle(widget.newsInfo.title),
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Container(
          padding: EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 3.0),
          child: Row(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(Icons.timer),
                  Text(widget.newsInfo.inputtime),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.remove_red_eye),
                  Text(widget.newsInfo.mview),
                ],
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.send),
                  Text(widget.newsInfo.source.split('@')[0]),
                ],
              ),
            ],
          )),
    ];

    if (_articleBody == null) {
      _content = Column(
        children: <Widget>[
          SizedBox(height: 100.0),
          CircularProgressIndicator(),
        ],
      );
    } else if (_articleBody[0] == 'failure') {
      _content = HtmlView(data: _articleBody[2]);
    } else {
      _content = Column(
        children: <Widget>[
          Card(
            color: Colors.white10,
            margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
            child: HtmlView(data: _articleBody[1]),
          ),
          HtmlView(data: _articleBody[2]),
        ],
      );
    }

    _body.add(_content);

    var _refreshIndicator = RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView(
        padding: EdgeInsets.all(8.0),
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
        String body =
            document.getElementsByClassName('article-body')[0].innerHtml;
        _result = <String>['success', summary, body];
        await prefs.setStringList(widget.newsInfo.sid, _result);
        return _result;
      } else {
        var siteError =
            document.getElementsByClassName('site-error')[0].innerHtml;
        var tips404 = document.getElementsByClassName('tips404');
        String statusCode = response.statusCode.toString();
        if (tips404 != null) {
          statusCode = '404';
        }
        return <String>['failure', statusCode, siteError];
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
