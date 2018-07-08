import 'package:flutter/material.dart';
// import 'dart:async';
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
  // List<String> _newsList = new List<String>();
  int _page = 1;

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
          _fetchNews(_newsList, _page++);
        }
        return new ListTile(
          title: new Text(_newsList[index].title),
          subtitle: new Text(_newsList[index].inputtime),
          trailing: new Container(
            width: 50.0,
            height: 50.0,
            decoration: new BoxDecoration(
              shape: BoxShape.circle,
              image: new DecorationImage(
                image: new NetworkImage(_newsList[index].thumb),
              ),
            ),
          ),
        );
      },
    );

    return content;
  }

  _fetchNews(List<NewsItem> result, int page) async {
    String url = 'https://m.cnbeta.com/touch/default/timeline.json';
    if (page != 1) {
      url += '?page=' + page.toString();
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
}

// class ContentState extends State<Content> {
//   final _newsList = <NewsItem>[];
//   int _page = 1;

//   @override
//   Widget build(BuildContext context) {
//     return new ListView.builder(
//       physics: AlwaysScrollableScrollPhysics(),
//       itemCount: _newsList.length,
//       itemBuilder: (context, i) {
//         if (i.isOdd) return new Divider();
//         final index = i - 2;
//         if (index >= _newsList.length && _page < 5) {
//           fetchNews(_newsList, _page++);
//         }
//         return new ListTile(
//           title: new Text(_newsList[index].title),
//           subtitle: new Text(_newsList[index].inputtime),
//           trailing: new Container(
//             width: 75.0,
//             height: 75.0,
//             decoration: new BoxDecoration(
//               shape: BoxShape.circle,
//               image: new DecorationImage(
//                 image: new NetworkImage(_newsList[index].thumb),
//               ),
//             ),
//           ),
//           // trailing: CachedNetworkImage(
//           //   placeholder: CircularProgressIndicator(),
//           //   imageUrl: _newsList[index].thumb,
//           // ),
//         );
//       },
//     );
//   }
// }
