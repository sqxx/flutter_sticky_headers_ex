# Flutter Sticky Headers Ex

Lets you place headers on scrollable content that will stick to the top of the container
whilst the content is scrolled.

## Differences from the original library
The ability to create side sticky headers has been added. See example #4

## Usage
You can place a `StickyHeader` or `StickyHeaderBuilder`
inside any scrollable content, such as:  `ListView`, `GridView`, `CustomScrollView`,
`SingleChildScrollView` or similar.

Depend on it:
```yaml
dependencies:
  sticky_headers:
    git:
      url: git://github.com/sqxx/flutter_sticky_headers_ex.git
```

Import it:
```dart
import 'package:sticky_headers/sticky_headers.dart';
```

Use it:
```dart
class Example extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new ListView.builder(itemBuilder: (context, index) {
      return new StickyHeader(
        header: new Container(
          height: 50.0,
          color: Colors.blueGrey[700],
          padding: new EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child: new Text('Header #$index',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        content: new Container(
          child: new Image.network(imageForIndex(index), fit: BoxFit.cover,
            width: double.infinity, height: 200.0),
        ),
      );
    });
  }
}
```

For more, see example/lib/main.dart

## Examples

### Example 1 - Headers and Content
![Demo 1](https://github.com/sqxx/flutter_sticky_headers_ex/img/1.gif)

### Example 2 - Animated Headers with Content
![Demo 2](https://github.com/sqxx/flutter_sticky_headers_ex/img/2.gif)

### Example 3 - Headers overlapping the Content
![Demo 3](https://github.com/sqxx/flutter_sticky_headers_ex/img/3.gif)

### Example 4 - Side headers with the Content
![Demo 3](https://github.com/sqxx/flutter_sticky_headers_ex/img/4.gif)

## Bugs/Requests
If you encounter any problems feel free to open an issue. If you feel the library is
missing a feature, please raise a ticket on Github and I'll look into it.
Pull request are also welcome.
