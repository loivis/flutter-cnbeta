import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cnbeta/news_info.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import './html_view/flutter_html_view.dart';

class NewsView extends StatefulWidget {
  final NewsInfo newsInfo;
  String _articleBody;

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
        title: new Text(widget.newsInfo.title),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    if (widget._articleBody == null) {
      return new Center(child: CircularProgressIndicator());
    }

    var _content = new Center(
      child: new HtmlView(data: widget._articleBody),
    );

    return _content;
  }

  Future<String> _getArticleBody() async {
    final _url = 'https://m.cnbeta.com' + widget.newsInfo.url;

    try {
      print(_url);
      final response = await http.get(_url);
      if (response.statusCode == 200) {
        var document = parse(response.body);
        var summary =
            document.getElementsByClassName('article-summary')[0].innerHtml;
        // print('summary: $summary');
        var body = document.getElementsByClassName('article-body')[0].innerHtml;
        // print('body: $body');
        return summary + '<b>正文</b>' + body;
      } else {
        throw Exception('failed to load news detail');
      }
    } catch (e) {
      print(e.toString());
    }

    return null;
  }
}
