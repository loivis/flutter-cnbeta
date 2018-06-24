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
        body: FutureBuilder<NewsItem>(
          future: fetchNews(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // return Text(snapshot.data.title);
              return new ListView(
                children: <Widget>[
                  new ListTile(
                    title: new Text(snapshot.data.title),
                    subtitle: new Text(snapshot.data.inputtime),
                    trailing: Image.network(snapshot.data.thumb),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Text('news');
  }
}

Future<NewsItem> fetchNews() async {
  final response =
      await http.get('https://m.cnbeta.com/touch/default/timeline.json');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON
    return NewsItem.fromJson(json.decode(response.body)['result']['list'][0]);
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load news');
  }
}
