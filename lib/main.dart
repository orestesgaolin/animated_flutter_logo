// Copyright 2020 Dominik Roszkowski <roszkowski.dev>

import 'dart:ui' as ui show Gradient;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_logo/matrix.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Animated Logo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  AnimationController animationController;
  int _currentDuration = 4;
  bool _showSettings = false;
  bool _showClippingPaths = false;
  bool _showOriginal = false;

  Animation<double> beamRotation;
  Animation<double> shadowOpacity;
  Animation<double> middleBeamTopClip;
  Animation<double> middleBeamTopBounce;
  Animation<double> bottomBeamBottomClip;
  Animation<double> bottomBeamTranslation;
  Animation<double> topBeamClip;
  Animation<double> topBeamBounceUp;
  Animation<double> topBeamBounceDown;
  Animation<double> scaleTween;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _currentDuration),
    );
    _initializeTweens();
    _startAnimation();
  }

  void _initializeTweens() {
    //anim last until 0.6
    final animLimit = 0.6;
    final tf = 140.0; //total frames

    //frames 63-102, modified
    beamRotation = Tween<double>(begin: math.pi, end: 0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          63 / tf * animLimit,
          110 / tf * animLimit,
          curve: Curves.easeInOutQuad,
        ),
      ),
    );

    shadowOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController, curve: Interval(0.5, 0.8)));

    //frames 40-67/140
    middleBeamTopClip = Tween<double>(begin: 1.0, end: 0.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(40 / tf * animLimit, 67 / tf * animLimit)));

    //frames 80-102, modified
    middleBeamTopBounce =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
            parent: animationController,
            curve: Interval(
              80 / tf * animLimit,
              120 / tf * animLimit,
              curve: Curves.easeInOutSine,
            )));

    //frames 54-78
    bottomBeamBottomClip =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
            parent: animationController,
            curve: Interval(
              54 / tf * animLimit,
              74 / tf * animLimit,
              curve: Curves.decelerate,
            )));

    //frames 78-100
    bottomBeamTranslation =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
            parent: animationController,
            curve: Interval(
              78 / tf * animLimit,
              100 / tf * animLimit,
              curve: Curves.decelerate,
            )));

    //frames 100-140
    topBeamClip = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          100 / tf * animLimit,
          140 / tf * animLimit,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    //frames 130-170
    topBeamBounceUp =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        100 / tf * animLimit,
        145 / tf * animLimit,
        curve: Curves.easeInOutSine,
      ),
    ));
    topBeamBounceDown =
        Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(
        145 / tf * animLimit,
        170 / tf * animLimit,
        curve: Curves.easeInOutSine,
      ),
    ));

    scaleTween = Tween<double>(begin: 1.03, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Interval(
          100 / tf * animLimit,
          170 / tf * animLimit,
          curve: Curves.easeInOut,
        ),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (MediaQuery.of(context).size.width > 600)
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: IconButton(
                icon: Icon(Icons.settings),
                color: _showSettings ? Colors.black54 : Colors.black12,
                onPressed: () {
                  setState(() {
                    _showSettings = !_showSettings;
                  });
                },
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (_showOriginal)
                    FlutterLogo(
                      size: 300,
                      style: FlutterLogoStyle.markOnly,
                    ),
                  AnimatedBuilder(
                    animation: animationController,
                    builder: (context, child) {
                      //workaround for small screens
                      var scale = 1.0;
                      if (MediaQuery.of(context).size.width < 600) {
                        scale = 0.7;
                      }
                      return Transform.scale(
                        scale: scaleTween.value * scale,
                        child: CustomPaint(
                          painter: AnimatedLogoPainter(
                              beamRotation: beamRotation.value,
                              middleBeamTopClip: middleBeamTopClip.value,
                              middleBeamTopBounce: middleBeamTopBounce.value,
                              shadowOpacity: shadowOpacity.value,
                              bottomBeamBottomClip: bottomBeamBottomClip.value,
                              bottomBeamTranslation:
                                  bottomBeamTranslation.value,
                              topBeamClip: topBeamClip.value,
                              topBeamBounce: topBeamBounceUp.value +
                                  topBeamBounceDown.value,
                              showClippingPaths: _showClippingPaths),
                          child: Container(
                            height: 300 * scale,
                            width: 300 * scale,
                            color: Colors.transparent,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (_showSettings)
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CheckboxListTile(
                        value: _showOriginal,
                        title: Text('Show original FlutterLogo'),
                        onChanged: (value) {
                          setState(() {
                            _showOriginal = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        value: _showClippingPaths,
                        title: Text('Show clipping paths'),
                        onChanged: (value) {
                          setState(() {
                            _showClippingPaths = value;
                          });
                        },
                      ),
                      ListTile(
                        title: Text('Animation duration ($_currentDuration s)'),
                        trailing: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FlatButton(
                              color: Colors.blue[200],
                              child: Text('Shorter'),
                              onPressed: _decreaseDuration,
                            ),
                            FlatButton(
                              color: Colors.blue[300],
                              child: Text('Longer'),
                              onPressed: _increaseDuration,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _decreaseDuration() {
    setState(() {
      _currentDuration = (_currentDuration - 1).clamp(1, 20);
      animationController.duration = Duration(seconds: _currentDuration);
    });
    _startAnimation();
  }

  void _increaseDuration() {
    setState(() {
      _currentDuration = (_currentDuration + 1).clamp(1, 20);
      animationController.duration = Duration(seconds: _currentDuration);
    });
    _startAnimation();
  }

  void _startAnimation() {
    animationController
      ..forward()
      ..repeat(reverse: true);
  }
}

// This is based on flutter_logo.dart file from Flutter
// Coordinates and selected painting approaches are taken from
// the Flutter source code
// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found at the bottom of this file
class AnimatedLogoPainter extends CustomPainter {
  final double beamRotation;
  final double shadowOpacity;
  final double middleBeamTopClip;
  final double bottomBeamBottomClip;
  final double bottomBeamTranslation;
  final double topBeamClip;
  final double topBeamBounce;
  final double middleBeamTopBounce;
  final bool showClippingPaths;

  AnimatedLogoPainter({
    this.beamRotation,
    this.shadowOpacity,
    this.middleBeamTopClip,
    this.bottomBeamBottomClip,
    this.bottomBeamTranslation,
    this.topBeamClip,
    this.topBeamBounce,
    this.middleBeamTopBounce,
    this.showClippingPaths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    // Coordinate space is 166x202 px
    // so we transform canvas and place it in the middle
    canvas.save();
    canvas.translate(rect.left, rect.top);
    canvas.scale(rect.width / 202.0, rect.height / 202.0);
    // Next, offset it some more so that the 166 horizontal pixels are centered
    // in that square (as opposed to being on the left side of it). This means
    // that if we draw in the rectangle from 0,0 to 166,202, we are drawing in
    // the center of the given rect.
    canvas.translate((202.0 - 166.0) / 2.0, 0.0);

    final lightPaint = Paint()..color = Colors.blue[400].withOpacity(0.8);
    final darkPaint = Paint()..color = Colors.blue[900];

    _drawTopBeam(canvas, lightPaint);
    _drawBottomDarkBeam(canvas, darkPaint);
    _drawMiddleBeam(canvas, lightPaint);

    if (beamRotation < math.pi / 2) {
      // rotate shadow only when over beam
      drawShadows(canvas);
    }

    canvas.restore();
  }

  void drawShadows(Canvas canvas) {
    ui.Gradient triangleGradient = _getTriangleGradient();
    final Paint trianglePaint = Paint()
      ..shader = triangleGradient
      ..blendMode = BlendMode.multiply;

    final Path triangle = Path()
      ..moveTo(79.5, 170.7)
      ..lineTo(120.9, 156.4)
      ..lineTo(107.4, 142.8);
    canvas.drawPath(triangle, trianglePaint);
  }

  void _drawMiddleBeam(Canvas canvas, Paint lightPaint) {
    canvas.save();

    _flipMiddleBeamWhenInTheMiddle(canvas);
    _rotateMiddleBeamAroundAxis(canvas);

    final topCornerPerspectiveOffset =
        beamRotation < math.pi / 2 ? middleBeamTopBounce * 40.0 : 0.0;
    final bottomCornerPerspectiveOffset =
        beamRotation > math.pi / 2 ? (beamRotation - math.pi) * 20.0 : 0.0;
    final xDistance = 100.4 - 51.6;
    final xDistance2 = 156.2 - 79.5;

    final Path middleBeam = Path()
      ..moveTo(
          156.2 + topCornerPerspectiveOffset, 94.0 - topCornerPerspectiveOffset)
      ..lineTo(100.4 + bottomCornerPerspectiveOffset,
          94.0 - topCornerPerspectiveOffset)
      ..lineTo(51.6, 142.8)
      ..lineTo(79.5, 170.7);

    // we clip the middle beam before rotating
    final distance = middleBeamTopClip * xDistance2;
    final margin = 30.0;
    final alongMargin = 50.0;
    final clippingPath = Path()
      ..moveTo(79.5 + distance + margin, 170.7 - distance + margin)
      ..lineTo(107.4 + xDistance + margin + alongMargin,
          142.8 - xDistance + margin - alongMargin)
      ..lineTo(79.5 + xDistance - margin + alongMargin,
          114.9 - xDistance - margin - alongMargin)
      ..lineTo(51.6 + distance - margin, 142.8 - distance - margin);
    canvas.clipPath(clippingPath);

    canvas.drawPath(middleBeam, lightPaint);
    canvas.restore();
    if (showClippingPaths) {
      canvas.save();
      canvas.drawPath(clippingPath, Paint()..color = Colors.pink);
      canvas.restore();
    }
  }

  void _flipMiddleBeamWhenInTheMiddle(Canvas canvas) {
    if (beamRotation > math.pi / 2) {
      // flip the middle beam when on the left side
      final rot2 = RotationMatrix(93.45, 128.85, 0.0, -1, 1, 0.0, math.pi);
      final mtx2 = rot2.getMatrix();
      canvas.transform(mtx2);
    }
  }

  void _rotateMiddleBeamAroundAxis(Canvas canvas) {
    final rot = RotationMatrix(79.5, 170.7, 0.0, 1, 1, 0.0, beamRotation);
    final mtx = rot.getMatrix();
    canvas.transform(mtx);
  }

  void _drawTopBeam(Canvas canvas, Paint lightPaint) {
    canvas.save();

    final clippingOffset = topBeamClip * (128.9);
    final clipPath = Path()
      ..moveTo(0.0, 128.9)
      ..lineTo(0.0, 0 + clippingOffset)
      ..lineTo(170.0, 0 + clippingOffset)
      ..lineTo(170.0, 128.9);

    canvas.clipPath(clipPath);

    final topOffset = topBeamBounce * 3.0;

    final Path topBeam = Path()
      ..moveTo(37.7, 128.9)
      ..lineTo(9.8, 101.0)
      ..lineTo(100.4 + topOffset, 10.4 - topOffset)
      ..lineTo(156.2 + topOffset, 10.4 - topOffset);
    canvas.drawPath(topBeam, lightPaint);
    canvas.restore();
    if (showClippingPaths) {
      canvas.save();
      canvas.drawPath(clipPath, Paint()..color = Colors.yellow);
      canvas.restore();
    }
  }

  void _drawBottomDarkBeam(Canvas canvas, Paint darkPaint) {
    canvas.save();

    final clippingOffset = bottomBeamBottomClip * (191.6 - 114.9 + 45);
    final clipPath = Path()
      ..moveTo(0.0, 0)
      ..lineTo(0.0, 191.6 - clippingOffset)
      ..lineTo(160.0, 191.6 - clippingOffset)
      ..lineTo(160.0, 114.9);

    canvas.clipPath(clipPath);

    final xStartOffset = (51.6 - 9.8) * bottomBeamTranslation;
    final yStartOffset = (142.8 - 101.0) * bottomBeamTranslation;
    final Path bottomDarkBeam = Path()
      ..moveTo(51.6 - xStartOffset, 142.8 - yStartOffset)
      ..lineTo(100.4, 191.6)
      ..lineTo(156.2, 191.6)
      ..lineTo(79.5 - xStartOffset, 114.9 - yStartOffset);

    canvas.drawPath(bottomDarkBeam, darkPaint);
    canvas.restore();

    if (showClippingPaths) {
      canvas.save();
      canvas.drawPath(clipPath, Paint()..color = Colors.green);
      canvas.restore();
    }
  }

  ui.Gradient _getTriangleGradient() {
    final triangleShadow = ui.Gradient.linear(
      const Offset(87.2623 + 37.9092, 28.8384 + 123.4389),
      const Offset(42.9205 + 37.9092, 35.0952 + 123.4389),
      <Color>[
        const Color(0xBFFFFFFF).withOpacity(shadowOpacity),
        const Color(0xBFFCFCFC).withOpacity(shadowOpacity),
        const Color(0xBFF4F4F4).withOpacity(shadowOpacity),
        const Color(0xBFE5E5E5).withOpacity(shadowOpacity),
        const Color(0xBFD1D1D1).withOpacity(shadowOpacity),
        const Color(0xBFB6B6B6).withOpacity(shadowOpacity),
        const Color(0xBF959595).withOpacity(shadowOpacity),
        const Color(0xBF6E6E6E).withOpacity(shadowOpacity),
        const Color(0xBF616161).withOpacity(shadowOpacity),
      ],
      <double>[
        0.2690,
        0.4093,
        0.4972,
        0.5708,
        0.6364,
        0.6968,
        0.7533,
        0.8058,
        0.8219
      ],
    );
    return triangleShadow;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// Copyright 2014 The Flutter Authors. All rights reserved.

// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:

//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above
//       copyright notice, this list of conditions and the following
//       disclaimer in the documentation and/or other materials provided
//       with the distribution.
//     * Neither the name of Google Inc. nor the names of its
//       contributors may be used to endorse or promote products derived
//       from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
// ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
// ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
