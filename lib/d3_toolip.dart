// Copyright (c) 2017, Rick Berger, Aphorica Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can
// be found in the LICENSE file.

/// Dart D3 Tooltips facility.  Provides tooltips for D3 selection items
/// in Dart
library D3Tooltip;

import 'dart:html' as Html;
import 'dart:async';

import 'package:d3/d3.dart';
import 'package:d3/selection.dart';
import 'package:aphorica_dartutils/utilities.dart' as AphUtils;

/// The class to be instantiated.  D3 selections are registered with
/// this instance.
///
class D3Tooltip {
  static final int _padding = 10;
  final Selection _svg;
  var _tip, _tipPointer, _tipRect, _tipText, _tipTextStr = '';
  String _dy;
  int _delaySecs, _durationSecs;
  Timer _delayTimer, _durationTimer;
  Html.Point _standoff, _showPt;

  ///  Constructor - Create a D3tooltip instance.
  ///  Args:
  ///     svg -- the svg root canvas
  ///
  ///     (All of the following are named optional parameters)
  ///     standoff - if provided, the x,y distances to stand off
  ///                           from the activation point.  A pointer will be
  ///                           constructed from the activation point to the
  ///                           corner of the rectangle.
  ///                           Default: 0, 0
  ///
  ///     delaySecs - the number of seconds to delay after entry to
  ///                     activate the tip.
  ///                     Default: 1
  ///
  ///     durationSecs - the number of seconds the tooltip is active.
  ///                     Default: 5
  ///
  ///     dy - the 'dy' attribute for the text.  You may have
  ///                     to fiddle with this if you resize the text and it
  ///                     doesn't center vertically.
  ///                     Default: '-0.31em'
  ///
  ///     rectClass - if specified, use this class for the rectangle and
  ///                 the offset pointer (if standoff has been specified).
  ///                 Default styles are: 'fill:black, rx:5, ry:5'
  ///
  ///     textClass - if specified, use this class for the text.
  ///                 Default styles are: 'fill:white, font-size:0.9rem'
  ///
  D3Tooltip(Selection this._svg, { Html.Point standoff,
                             int delaySecs = 1,
                             int durationSecs=5,
                             String dy='-0.31em',
                             String rectClass,
                             String textClass}) :

        _durationSecs = durationSecs,
        _delaySecs = delaySecs,
        _dy = dy,
        _standoff = standoff {
    _tip = _svg.append('g')
      ..style['visibility'] = 'hidden';

    _tipRect = _tip
      .append('rect');

    if (rectClass != null) {
      _tipRect.attr['class'] = rectClass;
    } else {
      _tipRect.style['fill'] = 'black';
      _tipRect.style['rx'] = 5;
      _tipRect.style['ry'] = 5;
    }

    if (_standoff != null) {
      var pathPoints = [
        [0, 0],
        [_standoff.x + 10, -_standoff.y],
        [_standoff.x, -standoff.y - 10],
        [0, 0]
      ];

      _tipPointer = _tip.append('g');
      _tipPointer.append('path')
        ..data([pathPoints])
        ..attrFn["d"] = (new Line());

      if (rectClass != null) {
        _tipPointer.attr['class'] = rectClass;
      } else {
        _tipPointer.style['fill'] = 'black';
      }
    }
    else {
      standoff = new Html.Point(0, 0);
    }

    _tipText = _tip.append('text')
        ..attr['dy'] = _dy;

    if (textClass != null) {
      _tipText.attr['class'] = textClass;
    } else {
      _tipText.style['fill'] = 'white';
      _tipText.style['font-size'] = '0.9rem';
    }
  }

  /// register a single selection
  /// 
  void registerSelection(dynamic sel) {
     sel.on('mouseenter').listen((_){ _entered(); });
     sel.on('mouseout').listen((_) { _hide(); });
  }

  /// register a selection collection
  /// 
  void registerSelections(dynamic sels) {
     sels.each((Html.Element el, dynamic s, int ix) {
       registerSelection(new Selection.elem(el));
     });
  }

  void _cancelTimers() {
    if (_delayTimer != null) {
      _delayTimer.cancel();
      _delayTimer = null;
    }

    if (_durationTimer != null) {
      _durationTimer.cancel();
      _durationTimer = null;
    }
  }

  void _entered() {
    _cancelTimers();
    _hide();
    var jsvg = event.target.ownerSvgElement;
    var pt = jsvg.createSvgPoint();
    pt.x = event.client.x;
    pt.y = event.client.y;
    var mtx = jsvg.getScreenCtm();
    var newPt = pt.matrixTransform(mtx.inverse());
    _showPt = new Html.Point(newPt.x, newPt.y);
              // back-transform the event point

    var text = AphUtils.searchAttrFromParentNode(event.target, 'desc');
    _delayTimer = new Timer(new Duration(seconds:_delaySecs), () { _show(text); });
  }

  void _show(String text) {
    if (_tipTextStr != text)
    {
      _delayTimer = null;
      
      _tipTextStr = text;
      _tipText.text = _tipTextStr;
      var bbox = _tipText.js.node().getBBox();
      if (_tipPointer != null) {
        _tipPointer.attr['transform'] = 'translate(${_showPt.x} ${_showPt.y})';
      }

      _tipRect.attr['width'] = bbox.width + _padding + _padding;
      _tipRect.attr['height'] = bbox.height + _padding + _padding;
      _tipRect.attr['x'] = _showPt.x + _standoff.x;
      _tipRect.attr['y'] = _showPt.y - _standoff.y - bbox.height - _padding - _padding;
      _tipText.attr['x'] = _showPt.x + _standoff.x + _padding ;
      _tipText.attr['y'] = _showPt.y - _standoff.y - _padding;
      _tip.style['visibility'] = 'visible';
      _durationTimer = new Timer(new Duration(seconds:_durationSecs), (){ _hide(); });
    }
  }

  void _hide() {
    bool cleanup = _durationTimer != null;
            // if not null, we need to hide

    _cancelTimers();

    if (cleanup) {
      _tip.style['visibility'] = 'hidden';
              // hide and ..

      _tipTextStr = '';
              // allow gc
    }
  }
}