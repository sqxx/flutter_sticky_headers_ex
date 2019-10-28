// Copyright 2018 Simon Lightfoot. All rights reserved.
// Use of this source code is governed by a the MIT license that can be
// found in the LICENSE file.

import 'dart:math' show min, max;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// Called every layout to provide the amount of stickyness a header is in.
/// This lets the widgets animate their content and provide feedback.
///
typedef void RenderStickyHeaderCallback(double stuckAmount);

/// RenderObject for StickyHeader widget.
///
/// Monitors given [Scrollable] and adjusts its layout based on its offset to
/// the scrollable's [RenderObject]. The header will be placed above content
/// unless overlapHeaders is set to true. The supplied callback will be used
/// to report the
///
class RenderStickyHeader extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, MultiChildLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, MultiChildLayoutParentData> {
  RenderStickyHeaderCallback _callback;
  ScrollableState _scrollable;
  bool _overlapHeaders;
  BuildContext _context;
  bool _offsetFromHeaders;
  double _contentLeftOffset;
  double _contentRightOffset;
  double _hardcodedHeadersWidth;

  RenderStickyHeader({
    @required ScrollableState scrollable,
    RenderStickyHeaderCallback callback,
    BuildContext context,
    bool overlapHeaders: false,
    offsetFromHeaders: false,
    hardcodedHeadersWidth,
    contentLeftOffset: 0.0,
    contentRightOffset: 0.0,
    RenderBox header,
    RenderBox content,
  })  : assert(scrollable != null),
        _scrollable = scrollable,
        _callback = callback,
        _context = context,
        _overlapHeaders = overlapHeaders,
        _offsetFromHeaders = offsetFromHeaders,
        _hardcodedHeadersWidth = hardcodedHeadersWidth,
        _contentLeftOffset = contentLeftOffset,
        _contentRightOffset = contentRightOffset {
    if (content != null) add(content);
    if (header != null) add(header);
  }

  set scrollable(ScrollableState value) {
    assert(value != null);
    if (_scrollable == value) {
      return;
    }
    final ScrollableState oldValue = _scrollable;
    _scrollable = value;
    markNeedsLayout();
    if (attached) {
      oldValue.position?.removeListener(markNeedsLayout);
      value.position?.addListener(markNeedsLayout);
    }
  }

  set callback(RenderStickyHeaderCallback value) {
    if (_callback == value) {
      return;
    }
    _callback = value;
    markNeedsLayout();
  }

  set overlapHeaders(bool value) {
    if (_overlapHeaders == value) {
      return;
    }
    _overlapHeaders = value;
    markNeedsLayout();
  }

  set hardcodedHeadersWidth(double value) {
    if (_hardcodedHeadersWidth == value) {
      return;
    }
    _hardcodedHeadersWidth = value;
    markNeedsLayout();
  }

  set offsetFromHeaders(bool value) {
    if (_offsetFromHeaders == value) {
      return;
    }
    _offsetFromHeaders = value;
    markNeedsLayout();
  }

  set contentLeftOffset(double value) {
    if (_contentLeftOffset == value) {
      return;
    }
    _contentLeftOffset = value;
    markNeedsLayout();
  }

  set contentRightOffset(double value) {
    if (_contentRightOffset == value) {
      return;
    }
    _contentRightOffset = value;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollable.position?.addListener(markNeedsLayout);
  }

  @override
  void detach() {
    _scrollable.position?.removeListener(markNeedsLayout);
    super.detach();
  }

  // short-hand to access the child RenderObjects
  RenderBox get _headerBox => lastChild;

  RenderBox get _contentBox => firstChild;

  @override
  void performLayout() {
    if (_overlapHeaders && _offsetFromHeaders)
      performSideHeaderLayout();
    else
      performNormalLayout();
  }

  void performSideHeaderLayout() {
    // ensure we have header and content boxes
    assert(childCount == 2);

    // layout both header and content widget
    final parentWidth = MediaQuery
        .of(_context)
        .size
        .width;

    final childConstraints = BoxConstraints(
      minWidth: 0.0,
      maxWidth: parentWidth,
      minHeight: 0.0,
      maxHeight: double.infinity,
    );

    _headerBox.layout(childConstraints, parentUsesSize: true);

    final headerWidth = _hardcodedHeadersWidth == null
        ? _headerBox.size.width
        : _hardcodedHeadersWidth;
    final headerHeight = _headerBox.size.height;

    final maxWidth =
        parentWidth - headerWidth - _contentRightOffset - _contentLeftOffset;

    // copy needs because size of _headerBox calculates only after .layout() method
    // without knowing the size _headerBox will not be able to calculate the size of the layout to _contentBox didn't go abroad
    final childConstraintsWithContent = childConstraints.copyWith(
      minWidth: headerWidth,
      maxWidth: maxWidth,
      minHeight: headerHeight,
      maxHeight: double.infinity,
    );

    _contentBox.layout(childConstraintsWithContent, parentUsesSize: true);

    final contentHeight = _contentBox.size.height;

    // determine size of ourselves based on content widget
    final width = max(constraints.minWidth, _contentBox.size.width);
    final height = max(constraints.minHeight,
        _overlapHeaders ? contentHeight : headerHeight + contentHeight);
    size = Size(width, height);

    assert(size.width == constraints.constrainWidth(width));
    assert(size.height == constraints.constrainHeight(height));
    assert(size.isFinite);

    // place content underneath header
    final contentParentData =
    _contentBox.parentData as MultiChildLayoutParentData;

    contentParentData.offset = Offset(
        _offsetFromHeaders ? headerWidth + _contentLeftOffset : 0.0,
        _overlapHeaders ? 0.0 : headerHeight);

    // determine by how much the header should be stuck to the top
    final double stuckOffset = determineStuckOffset();

    // place header over content relative to scroll offset
    final double maxOffset = height - headerHeight;
    final headerParentData =
    _headerBox.parentData as MultiChildLayoutParentData;
    headerParentData.offset =
        Offset(0.0, max(0.0, min(-stuckOffset, maxOffset)));

    // report to widget how much the header is stuck.
    if (_callback != null) {
      final stuckAmount =
          max(min(headerHeight, stuckOffset), -headerHeight) / headerHeight;
      _callback(stuckAmount);
    }
  }

  void performNormalLayout() {
    // ensure we have header and content boxes
    assert(childCount == 2);

    // layout both header and content widget
    final childConstraints = constraints.loosen();
    _headerBox.layout(childConstraints, parentUsesSize: true);
    _contentBox.layout(childConstraints, parentUsesSize: true);

    final headerHeight = _headerBox.size.height;
    final contentHeight = _contentBox.size.height;

    // determine size of ourselves based on content widget
    final width = max(constraints.minWidth, _contentBox.size.width);
    final height = max(constraints.minHeight,
        _overlapHeaders ? contentHeight : headerHeight + contentHeight);
    size = Size(width, height);
    assert(size.width == constraints.constrainWidth(width));
    assert(size.height == constraints.constrainHeight(height));
    assert(size.isFinite);

    // place content underneath header
    final contentParentData =
    _contentBox.parentData as MultiChildLayoutParentData;
    contentParentData.offset =
        Offset(0.0, _overlapHeaders ? 0.0 : headerHeight);

    // determine by how much the header should be stuck to the top
    final double stuckOffset = determineStuckOffset();

    // place header over content relative to scroll offset
    final double maxOffset = height - headerHeight;
    final headerParentData =
    _headerBox.parentData as MultiChildLayoutParentData;
    headerParentData.offset =
        Offset(0.0, max(0.0, min(-stuckOffset, maxOffset)));

    // report to widget how much the header is stuck.
    if (_callback != null) {
      final stuckAmount =
          max(min(headerHeight, stuckOffset), -headerHeight) / headerHeight;
      _callback(stuckAmount);
    }
  }

  double determineStuckOffset() {
    final scrollBox = _scrollable.context.findRenderObject();
    if (scrollBox?.attached ?? false) {
      try {
        return localToGlobal(Offset.zero, ancestor: scrollBox).dy;
      } catch (e) {
        // ignore and fall-through and return 0.0
      }
    }
    return 0.0;
  }

  @override
  void setupParentData(RenderObject child) {
    super.setupParentData(child);
    if (child.parentData is! MultiChildLayoutParentData) {
      child.parentData = MultiChildLayoutParentData();
    }
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return _contentBox.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return _contentBox.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return _overlapHeaders
        ? _contentBox.getMinIntrinsicHeight(width)
        : (_headerBox.getMinIntrinsicHeight(width) +
            _contentBox.getMinIntrinsicHeight(width));
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return _overlapHeaders
        ? _contentBox.getMaxIntrinsicHeight(width)
        : (_headerBox.getMaxIntrinsicHeight(width) +
            _contentBox.getMaxIntrinsicHeight(width));
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
