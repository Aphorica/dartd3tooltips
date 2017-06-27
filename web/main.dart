// Copyright (c) 2017, Rick Berger. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
import 'dart:html' as Html;
import 'package:d3/d3.dart';
import 'd3_tooltip.dart';

void main() {
  int xdiv = 4, ydiv = 4;

  int xoffset = 200, yoffset = 200;
  
  Html.Element plotCtnr = Html.querySelector('#plot-ctnr');
  plotCtnr.style.left = '${xoffset}px';
  plotCtnr.style.top = '${yoffset}px';
  plotCtnr.style.width = '${Html.window.innerWidth - xoffset}px';
  plotCtnr.style.height = '${Html.window.innerHeight - yoffset}px';


  // new Future.delayed(new Duration()).then((_) {
  Html.Rectangle plotRect = plotCtnr.getBoundingClientRect();
  int plotHeight = plotRect.height,
      plotWidth = plotRect.width;

  int radius = plotWidth ~/ 20;

  
  final List<Map> circleCoords = <Map>[
    {'x': plotWidth ~/ xdiv, 'y': plotHeight ~/ ydiv, 'color': 'red', 'tip': 'Red Circle'},
    {'x': (plotWidth ~/ xdiv) * (xdiv - 1), 'y': (plotHeight ~/ 2), 'color': 'yellow', 'tip': 'Yellow Circle'},
    {'x': plotWidth ~/ 2, 'y': (plotHeight ~/ ydiv) * (ydiv - 1), 'color': 'cyan', 'tip': 'Cyan Circle'}
  ];

  final List<Map> squareCoords = <Map>[
    {'x': circleCoords[2]['x'], 'y': circleCoords[0]['y'], 'color': 'green', 'tip': 'Green Square'},
    {'x': circleCoords[0]['x'], 'y': circleCoords[1]['y'], 'color': 'blue', 'tip': 'Blue Square'}
  ];

  print('In main...');
  Selection svg = new Selection('#plot-ctnr').append("svg")
     ..attr['width'] = '${plotWidth}'
     ..attr['height'] = '${plotHeight}';

  svg.append('rect')
    ..attr['fill'] = '#f0f8ff'
    ..attr['width'] = '$plotWidth'
    ..attr['height'] = '$plotHeight';

  Selection circles = svg.selectAll('circles')
    .data(circleCoords)
    .enter()
      .append('circle')
      ..attrFn['cx'] = ((d) => d['x'])
      ..attrFn['cy'] = ((d) => d['y'])
      ..attrFn['desc'] = ((d) => d['tip'])
      ..attr['r'] = '$radius'
      ..styleFn['fill'] = ((d) => d['color'])
      ..style['stroke'] = 'black';

  Selection squares = svg.selectAll('squares')
    .data(squareCoords)
    .enter()
      .append('g')
        ..attrFn['transform'] = ((d) {
          num x = d['x'], y = d['y'];
          return
                 // "translate(-${radius/2},-${radius/2}) "
                 "translate(${x - radius},${y - radius}) "
                 "scale(2.0) "
                 ;
          });

  squares.each((Html.Element s, dynamic d, int i) {
    new Selection.elem(s).append('rect')
      ..attr['width'] = '$radius'
      ..attr['height'] = '$radius'
      ..attrFn['fill'] = ((d) => d['color'])
      ..attrFn['desc'] = ((d) => d['tip']);
     });

  D3Tooltip tip = new D3Tooltip(svg, standoff: new Html.Point(30, 30));
  tip.registerSelections(circles);
  tip.registerSelections(squares);
}
