// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:math';

import 'package:digital_clock/UIUtils/HexColor.dart';
import 'package:digital_clock/UIUtils/clockAppTheme.dart';
import 'package:digital_clock/UIUtils/waveView.dart';
import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:simple_animations/simple_animations/controlled_animation.dart';

enum _Element {
  background,
  text,
}

final _darkTheme = {
  _Element.background: Color(0xff212435),
  _Element.text: Colors.white,
};

class DigitalClock extends StatefulWidget {
  const DigitalClock(this.model);

  final ClockModel model;

  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;
  String weatherIcon = "assets/images/sunny.png";
  String timeOfDayIcon = "assets/images/sunny.png";
  String timeOfDay = "Morning";
  String tempCondition = "warm";

  @override
  void initState() {
    _updateWeatherCondition();
    _updateTempCondition();
    super.initState();
    widget.model.addListener(_updateModel);
    _showTimeOfDay();
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  void _updateTempCondition() {
    var arr = widget.model.temperatureString.split('.');
    var temp = int.parse(arr[0]);
    if (temp < 16) {
      setState(() {
        tempCondition = "Chilly";
      });
    } else if (temp < 50) {
      setState(() {
        tempCondition = "Just Cold";
      });
    } else if (temp > 50) {
      setState(() {
        tempCondition = "Kinda hot";
      });
    } else if (temp > 70) {
      setState(() {
        tempCondition = "Very Hot";
      });
    }
  }
  // shows if the time is morning or afternoon or evening
  void _showTimeOfDay() {
    var hour = DateTime.now().hour;
    if (hour == 0 || hour < 12) {
      setState(() {
        timeOfDay = "Morning";
        timeOfDayIcon = "assets/images/dawn.png";
        _updateTime();
      });
    } else if (hour < 17) {
      setState(() {
        timeOfDay = "Afternoon";
        timeOfDayIcon = "assets/images/sunny.png";
        _updateTime();
      });
    } else {
      setState(() {
        timeOfDay = "Evening";
        timeOfDayIcon = "assets/images/moon.png";
        _updateTime();
      });
    }
  }

  // controls the weather icon to show if it is sunny or rainy

  void _updateWeatherCondition() {
    setState(() {
      switch (widget.model.weatherString) {
        case "cloudy":
          {
            weatherIcon = "assets/images/cloudy.png";
          }
          break;

        case "sunny":
          {
            weatherIcon = "assets/images/sunny.png";
          }
          break;

        case "thunderstorm":
          {
            weatherIcon = "assets/images/thunderstorm.png";
          }
          break;

        case "windy":
          {
            weatherIcon = "assets/images/wind.png";
          }
          break;

        case "snowy":
          {
            weatherIcon = "assets/images/snowy.png";
          }
          break;

        case "foggy":
          {
            weatherIcon = "assets/images/fog.png";
          }
          break;

        case "rainy":
          {
            weatherIcon = "assets/images/rain.png";
          }
          break;

        default:
          {
            weatherIcon = "assets/images/sunny.png";
          }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  // called if an item on the clock model is changed

  void _updateModel() {
    setState(() {
      _updateWeatherCondition();
      _updateTempCondition();
      // Cause the clock to rebuild when the model changes.
    });
  }


  // update the hour and minute widget and also changes the time of the day
  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        _showTimeOfDay,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = _darkTheme;
    final hour = DateFormat(widget.model.is24HourFormat ? 'HH' : 'hh').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final fontSize = MediaQuery.of(context).size.width / 5;

    // default style for text widget
    final defaultStyle = TextStyle(
      color: colors[_Element.text],
      fontFamily: 'DS',
      fontSize: fontSize,
    );

    return Container(
      color: colors[_Element.background],
      child: DefaultTextStyle(
        style: defaultStyle,
        child: Stack(
          children: <Widget>[
            Positioned.fill(child: AnimatedBackground()),
            onBottom(AnimatedWave(
              height: 180,
              speed: 1.0,
            )),
            onBottom(AnimatedWave(
              height: 120,
              speed: 0.9,
              offset: pi,
            )),
            onBottom(AnimatedWave(
              height: 220,
              speed: 1.2,
              offset: pi / 2,
            )),

            // HOur and minute widget
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
              child: Center(
                child: Container(
                    child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 30.0),
                          child: Text(hour),
                        ),
                        Text(":"),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Text(minute),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        widget.model.location,
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                    ),
                  ],
                )),
              ),
            ),
            //  shows the time of the day eg: Morning, Afternoon or Evening
            Positioned(
                right: 20,
                top: 10,
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      timeOfDayIcon,
                      width: 25,
                      height: 25,
                    ),
                    Text(
                      timeOfDay,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                )),

            // representation of the temperature of the day in a liquid bottle
            Positioned(
                left: 20,
                bottom: 10,
                child: Row(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: 40,
                          height: 100,
                          decoration: BoxDecoration(
                            color: HexColor("#E8EDFE"),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(80.0),
                                bottomLeft: Radius.circular(80.0),
                                bottomRight: Radius.circular(80.0),
                                topRight: Radius.circular(80.0)),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: ClockAppTheme.grey.withOpacity(0.4),
                                  offset: Offset(2, 2),
                                  blurRadius: 4),
                            ],
                          ),
                          child: WaveView(widget.model),
                        ),
                        Text(
                          widget.model.temperatureString,
                          style: TextStyle(
                              color: Color(0xff212435),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          tempCondition,
                          style: TextStyle(
                              color: Color(0xff212435),
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, top: 20),
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            weatherIcon,
                            width: 50,
                            height: 50,
                          ),
                          Text(
                            widget.model.weatherString,
                            style: TextStyle(
                                color: Color(0xff212435),
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

// drawing the curves on the waves
class CurvePainter extends CustomPainter {
  final double value;

  CurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.6 + 0.4 * y1);
    final controlPointY = size.height * (0.6 + 0.4 * y2);
    final endPointY = size.height * (0.6 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

// animation class for the wave

class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTrackTween([
      Track("color1").add(Duration(minutes: 1),
          ColorTween(begin: Color(0xFF3A5160), end: Colors.blue.shade600)),
      Track("color2").add(Duration(minutes: 1),
          ColorTween(begin: Color(0xffD38312), end: Colors.lightBlue.shade900)),
      Track("color3").add(Duration(minutes: 1),
          ColorTween(begin: Color(0xff212435), end: Colors.black54))
    ]);

    return ControlledAnimation(
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                animation["color1"],
                animation["color2"],
                animation["color3"]
              ])),
        );
      },
    );
  }
}
