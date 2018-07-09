import 'package:flutter/material.dart';
import 'package:cnbeta/news.dart';

class NewsDetail extends StatelessWidget {
  News news;

  NewsDetail(this.news);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(news.title),
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    return new Container(
      child: new Text(news.source),
    );
  }
}
