import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cnbeta/news_item.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'cnBeta News',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('cnBeta 资讯'),
        ),
        body: new Content(),
      ),
    );
  }
}

class Content extends StatefulWidget {
  @override
  createState() => new ContentState();
}

class ContentState extends State<Content> {
  final _newsList = <NewsItem>[];
  int _page = 1;

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemBuilder: (context, i) {
        if (i.isOdd) return new Divider();
        final index = i ~/ 2;
        if (index >= _newsList.length) {
          fetchNews(_newsList, _page++);
        }
        return new ListTile(
          title: new Text(_newsList[index].title),
          subtitle: new Text(_newsList[index].inputtime),
          trailing: Image.network(_newsList[index].thumb),
        );
      },
    );
  }
}

fetchNews(List<NewsItem> result, int page) async {
  String url = 'https://m.cnbeta.com/touch/default/timeline.json?page=' +
      page.toString();
  if (page == 1) {
    url = 'https://m.cnbeta.com/touch/default/timeline.json';
  }
  print(url);
  final response = await http.get(url);

  if (response.statusCode == 200) {
    for (var item in json.decode(response.body)['result']['list']) {
      result.add(NewsItem.fromJson(item));
    }
  } else {
    throw Exception('Failed to load news');
  }
}
