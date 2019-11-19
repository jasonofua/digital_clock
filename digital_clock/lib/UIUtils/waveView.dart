import 'package:digital_clock/UIUtils/clockAppTheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as vector;

class WaveView extends StatefulWidget {

  const WaveView(this.model);

  final ClockModel model;
  @override
  _WaveViewState createState() => _WaveViewState();
}

class _WaveViewState extends State<WaveView> with TickerProviderStateMixin {
  AnimationController animationController;
  AnimationController waveAnimationController;
  Size bottlesize1 = Size(60, 100);
  Offset bottleOffset1 = Offset(0, 0);
  List<Offset> animList1 = [];


  Size bottlesize2 = Size(60, 100);
  Offset bottleOffset2 = Offset(0, 0);
  List<Offset> animList2 = [];
  @override
  void initState() {
    var arr = widget.model.temperatureString.split('.');
    var temp = int.parse(arr[0]);

    print(temp);

    animationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    waveAnimationController = AnimationController(
        duration: Duration(milliseconds: 2000), vsync: this);
    animationController
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          animationController.forward();
        }
      });
    waveAnimationController.addListener(() {
      animList1.clear();
      for (int i = -2 - bottleOffset1.dx.toInt(); i <= 60 + 2; i++) {
        animList1.add(new Offset(
            i.toDouble() + bottleOffset1.dx.toInt(),
            math.sin((waveAnimationController.value * 360 - i) %
                        360 *
                        vector.degrees2Radians) *
                    4 +
                temp));
      }
      animList2.clear();
      for (int i = -2 - bottleOffset2.dx.toInt(); i <= 60 + 2; i++) {
        animList2.add(new Offset(
            i.toDouble() + bottleOffset2.dx.toInt(),
            math.sin((waveAnimationController.value * 360 - i) %
                        360 *
                        vector.degrees2Radians) *
                    4 +
               temp));
      }
    });
    waveAnimationController.repeat();
    animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    waveAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: new AnimatedBuilder(
        animation: new CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOut,
        ),
        builder: (context, child) => new Stack(
          children: <Widget>[
            new ClipPath(
              child: Stack(
                children: <Widget>[
                  new Container(
                    decoration: BoxDecoration(
                      color: ClockAppTheme.nearlyDarkBlue.withOpacity(0.5),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(80.0),
                          bottomLeft: Radius.circular(80.0),
                          bottomRight: Radius.circular(80.0),
                          topRight: Radius.circular(80.0)),
                      gradient: LinearGradient(
                        colors: [
                          ClockAppTheme.nearlyDarkBlue.withOpacity(0.2),
                          ClockAppTheme.nearlyDarkBlue.withOpacity(0.5)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ),
              clipper: new WaveClipper(animationController.value, animList1),
            ),
            new ClipPath(
              child: Stack(
                children: <Widget>[
                  new Container(
                    decoration: BoxDecoration(
                      color: ClockAppTheme.nearlyDarkRed,
                      gradient: LinearGradient(
                        colors: [
                          ClockAppTheme.nearlyDarkBlue,
                          ClockAppTheme.nearlyDarkRed
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(80.0),
                          bottomLeft: Radius.circular(80.0),
                          bottomRight: Radius.circular(80.0),
                          topRight: Radius.circular(80.0)),
                    ),
                  ),
                ],
              ),
              clipper: new WaveClipper(animationController.value, animList2),
            ),

            Positioned(
              top: 0,
              left: 6,
              bottom: 8,
              child: new ScaleTransition(
                alignment: Alignment.center,
                scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animationController,
                    curve: Interval(0.0, 1.0, curve: Curves.fastOutSlowIn))),
                child: Container(
                  width: 2,
                  height: 2,
                  decoration: BoxDecoration(
                    color: ClockAppTheme.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 0,
              bottom: 16,
              child: new ScaleTransition(
                alignment: Alignment.center,
                scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animationController,
                    curve: Interval(0.4, 1.0, curve: Curves.fastOutSlowIn))),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ClockAppTheme.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 24,
              bottom: 32,
              child: new ScaleTransition(
                alignment: Alignment.center,
                scale: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animationController,
                    curve: Interval(0.6, 0.8, curve: Curves.fastOutSlowIn))),
                child: Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: ClockAppTheme.white.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 20,
              bottom: 0,
              child: new Transform(
                transform: new Matrix4.translationValues(
                    0.0, 16 * (1.0 - animationController.value), 0.0),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ClockAppTheme.white.withOpacity(
                        animationController.status == AnimationStatus.reverse
                            ? 0.0
                            : 0.4),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                 AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset("assets/images/bottle.png"),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  final double animation;

  List<Offset> waveList1 = [];

  WaveClipper(this.animation, this.waveList1);

  @override
  Path getClip(Size size) {
    Path path = new Path();

    path.addPolygon(waveList1, false);

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      animation != oldClipper.animation;
}
