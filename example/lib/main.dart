import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:sticky_headers/sticky_headers.dart';

import './images.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticky Headers Example',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Sticky Headers Example',
      child: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: <Widget>[
            ListTile(
              title: const Text('Example 1 - Headers and Content'),
              onTap: () => navigateTo(context, (context) => Example1()),
            ),
            ListTile(
              title: const Text('Example 2 - Animated Headers with Content'),
              onTap: () => navigateTo(context, (context) => Example2()),
            ),
            ListTile(
              title: const Text('Example 3 - Headers overlapping the Content'),
              onTap: () => navigateTo(context, (context) => Example3()),
            ),
            ListTile(
              title: const Text('Example 4 - Side header and Content'),
              onTap: () => navigateTo(context, (context) => Example4()),
            ),
          ],
        ).toList(growable: false),
      ),
    );
  }

  navigateTo(BuildContext context, builder(BuildContext context)) {
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }
}

class Example1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Example 1',
      child: ListView.builder(itemBuilder: (context, index) {
        return Material(
          color: Colors.grey[300],
          child: StickyHeader(
            header: Container(
              height: 50.0,
              color: Colors.blueGrey[700],
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: Text(
                'Header #$index',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            content: Container(
              child: Image.network(imageForIndex(index),
                  fit: BoxFit.cover, width: double.infinity, height: 200.0),
            ),
          ),
        );
      }),
    );
  }

  String imageForIndex(int index) {
    return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
  }
}

class Example2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Example 2',
      child: ListView.builder(itemBuilder: (context, index) {
        return Material(
          color: Colors.grey[300],
          child: StickyHeaderBuilder(
            builder: (BuildContext context, double stuckAmount) {
              stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
              return Container(
                height: 50.0,
                color:
                Color.lerp(Colors.blue[700], Colors.red[700], stuckAmount),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Header #$index',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Offstage(
                      offstage: stuckAmount <= 0.0,
                      child: Opacity(
                        opacity: stuckAmount,
                        child: IconButton(
                          icon: Icon(Icons.favorite, color: Colors.white),
                          onPressed: () =>
                              Scaffold.of(context).showSnackBar(
                                  SnackBar(content: Text('Favorite #$index'))),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            content: Container(
              child: Image.network(imageForIndex(index),
                  fit: BoxFit.cover, width: double.infinity, height: 200.0),
            ),
          ),
        );
      }),
    );
  }

  String imageForIndex(int index) {
    return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
  }
}

class Example3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Example 3',
      child: ListView.builder(itemBuilder: (context, index) {
        return Material(
          color: Colors.grey[300],
          child: StickyHeaderBuilder(
            overlapHeaders: true,
            builder: (BuildContext context, double stuckAmount) {
              stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
              return Container(
                height: 50.0,
                color: Colors.grey[900].withOpacity(0.6 + stuckAmount * 0.4),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Header #$index',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            },
            content: Container(
              child: Image.network(imageForIndex(index),
                  fit: BoxFit.cover, width: double.infinity, height: 200.0),
            ),
          ),
        );
      }),
    );
  }

  String imageForIndex(int index) {
    return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
  }
}

class Example4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldWrapper(
      title: 'Example 4',
      child: ListView.builder(itemBuilder: (context, index) {
        return StickyHeaderBuilder(
            overlapHeaders: true,
            offsetFromHeaders: true,
            builder: (BuildContext context, double stuckAmount) {
              stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Header\n#$index',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black),
                ),
              );
            },
            content: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.network(
                imageForIndex(index),
                fit: BoxFit.fitWidth,
                width: double.infinity,
                height: 200.0,
              ),
            ));
      }),
    );
  }

  String imageForIndex(int index) {
    return Images.imageThumbUrls[index % Images.imageThumbUrls.length];
  }
}

class ScaffoldWrapper extends StatelessWidget {
  final Widget child;
  final String title;

  const ScaffoldWrapper({
    Key key,
    @required this.title,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Hero(
          tag: 'app_bar',
          child: AppBar(
            title: Text(title),
            elevation: 0.0,
          ),
        ),
      ),
      body: child,
    );
  }
}
