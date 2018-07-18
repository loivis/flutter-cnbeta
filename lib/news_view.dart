import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cnbeta/news_info.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:flutter_html_view/flutter_html_view.dart';
import './utils.dart';

class NewsView extends StatefulWidget {
  final NewsInfo newsInfo;
  List<String> _articleBody;

  NewsView(this.newsInfo);

  @override
  State<StatefulWidget> createState() {
    return new _NewsViewState();
  }
}

class _NewsViewState extends State<NewsView> {
  @override
  void initState() {
    super.initState();
    if (widget._articleBody == null) {
      _getArticleBody().then((result) {
        setState(() {
          widget._articleBody = result;
        });
      });
    }
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

    if (widget._articleBody == null) {
      _content = new Center(child: CircularProgressIndicator());
    } else {
      _content = new Column(
        children: <Widget>[
          new Card(
            margin: new EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
            child: new HtmlView(data: widget._articleBody[0]),
          ),
          new HtmlView(data: widget._articleBody[1]),
        ],
      );
    }

    _body.add(_content);

    return new ListView(
      padding: new EdgeInsets.all(8.0),
      children: _body,
    );
  }

  Future<List<String>> _getArticleBody() async {
    final _url = 'https://m.cnbeta.com' + widget.newsInfo.url;

    try {
      print(_url);
      final response = await http.get(_url);
      if (response.statusCode == 200) {
        var document = parse(response.body);
        var summary =
            document.getElementsByClassName('article-summary')[0].innerHtml;
        // print('summary: $summary');
        // data-* attributes are not supported by flutter_html_view
        // https://github.com/PonnamKarthik/FlutterHtmlView/issues/13
        var body = document
            .getElementsByClassName('article-body')[0]
            .innerHtml
            .replaceAll(new RegExp('data-[a-z]+="[^\"]+"'), '');
        // print('body: $body');
        return <String>[summary, body];
      } else {
        throw Exception('failed to load news detail');
      }
    } catch (e) {
      print(e.toString());
    }

    return null;
  }
}
