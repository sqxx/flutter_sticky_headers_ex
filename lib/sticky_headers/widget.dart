// Copyright 2018 Simon Lightfoot. All rights reserved.
// Use of this source code is governed by a the MIT license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import './render.dart';

/// Builder called during layout to allow the header's content to be animated or styled based
/// on the amount of stickyness the header has.
///
/// [context] for your build operation.
///
/// [stuckAmount] will have the value of:
/// ```
///   0.0 <= value <= 1.0: about to be stuck
///          0.0 == value: at top
///  -1.0 >= value >= 0.0: past stuck
/// ```
///
typedef Widget StickyHeaderWidgetBuilder(BuildContext context,
    double stuckAmount);

/// Stick Header Widget
///
/// Will layout the [header] above the [content] unless the [overlapHeaders] boolean is set to true.
/// The [header] will remain stuck to the top of its parent [Scrollable] content.
///
/// Place this widget inside a [ListView], [GridView], [CustomScrollView], [SingleChildScrollView] or similar.
///
class StickyHeader extends MultiChildRenderObjectWidget {
  /// Constructs a  [StickyHeader] widget.
  StickyHeader({
    Key key,
    @required this.context,
    @required this.header,
    @required this.content,
    this.overlapHeaders: false,
    this.offsetFromHeaders: false,
    this.hardcodedHeadersWidth,
    this.contentLeftOffset: 0.0,
    this.contentRightOffset: 0.0,
    this.callback,
  }) : super(
          key: key,
          children: [content, header],
        );

  final BuildContext context;

  /// Header to be shown at the top of the parent [Scrollable] content.
  final Widget header;

  /// Content to be shown below the header.
  final Widget content;

  /// If true, the header will overlap the content.
  final bool overlapHeaders;

  /// Hardcoded header width
  final double hardcodedHeadersWidth;

  /// If true, the content will offset from the header.
  final bool offsetFromHeaders;

  /// The offset of the content from the left edge
  final double contentLeftOffset;

  /// The offset of the content from the right edge
  final double contentRightOffset;

  /// Optional callback with stickyness value. If you think you need this, then you might want to
  /// consider using [StickyHeaderBuilder] instead.
  final RenderStickyHeaderCallback callback;

  @override
  RenderStickyHeader createRenderObject(BuildContext context) {
    var scrollable = Scrollable.of(context);
    assert(scrollable != null);

    return RenderStickyHeader(
      context: context,
      scrollable: scrollable,
      callback: this.callback,
      overlapHeaders: this.overlapHeaders,
      offsetFromHeaders: this.offsetFromHeaders,
      hardcodedHeadersWidth: this.hardcodedHeadersWidth,
      contentLeftOffset: this.contentLeftOffset,
      contentRightOffset: this.contentRightOffset,
    );
  }

  @override
  void updateRenderObject(BuildContext context,
      RenderStickyHeader renderObject) {
    renderObject
      ..scrollable = Scrollable.of(context)
      ..callback = this.callback
      ..overlapHeaders = this.overlapHeaders
      ..hardcodedHeadersWidth = this.hardcodedHeadersWidth
      ..offsetFromHeaders = this.offsetFromHeaders
      ..contentLeftOffset = this.contentLeftOffset
      ..contentRightOffset = this.contentRightOffset;
  }
}

/// Sticky Header Builder Widget.
///
/// The same as [StickyHeader] but instead of supplying a Header view, you supply a [builder] that
/// constructs the header with the appropriate stickyness.
///
/// Place this widget inside a [ListView], [GridView], [CustomScrollView], [SingleChildScrollView] or similar.
///
class StickyHeaderBuilder extends StatefulWidget {
  /// Constructs a new [StickyHeaderBuilder] widget.
  const StickyHeaderBuilder({
    Key key,
    @required this.builder,
    this.content,
    this.overlapHeaders: false,
    this.offsetFromHeaders: false,
    this.hardcodedHeadersWidth,
    this.contentLeftOffset: 0.0,
    this.contentRightOffset: 0.0,
  }) : super(key: key);

  /// Called when the sticky amount changes for the header.
  /// This builder must not return null.
  final StickyHeaderWidgetBuilder builder;

  /// Content to be shown below the header.
  final Widget content;

  /// If true, the header will overlap the Content.
  final bool overlapHeaders;

  /// If true, the content will offset from the header.
  final bool offsetFromHeaders;

  /// Hardcoded header width
  final double hardcodedHeadersWidth;

  /// The offset of the content from the left edge
  final double contentLeftOffset;

  /// The offset of the content from the right edge
  final double contentRightOffset;

  @override
  _StickyHeaderBuilderState createState() => _StickyHeaderBuilderState();
}

class _StickyHeaderBuilderState extends State<StickyHeaderBuilder> {
  double _stuckAmount;

  @override
  Widget build(BuildContext context) {
    return StickyHeader(
      context: context,
      overlapHeaders: widget.overlapHeaders,
      offsetFromHeaders: widget.offsetFromHeaders,
      hardcodedHeadersWidth: widget.hardcodedHeadersWidth,
      contentLeftOffset: widget.contentLeftOffset,
      contentRightOffset: widget.contentRightOffset,
      header: LayoutBuilder(
        builder: (context, _) => widget.builder(context, _stuckAmount ?? 0.0),
      ),
      content: widget.content,
      callback: (double stuckAmount) {
        if (_stuckAmount != stuckAmount) {
          _stuckAmount = stuckAmount;
          WidgetsBinding.instance.endOfFrame.then((_) => setState(() {}));
        }
      },
    );
  }
}
