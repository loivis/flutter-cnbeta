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
  final newsList = <NewsItem>[];

  // for (var news in items) {

  // };

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemBuilder: (context, i) {
        if (i.isOdd) return new Divider();
        final index = i ~/ 2;
        if (index >= newsList.length) {
          fetchNews(newsList);
        }
        return new ListTile(
          title: new Text(newsList[index].title),
          subtitle: new Text(newsList[index].inputtime),
          trailing: Image.network(newsList[index].thumb),
        );
      },
    );
  }
}

fetchNews(List<NewsItem> result) async {
  final response =
      await http.get('https://m.cnbeta.com/touch/default/timeline.json');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    for (var item in json.decode(response.body)['result']['list']) {
      result.add(NewsItem.fromJson(item));
    }
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load news');
  }
}
