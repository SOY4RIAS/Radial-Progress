import 'dart:math' as Math;

import 'package:flutter/material.dart';

class RadialProgress extends StatefulWidget {

  final double percent;
  final Color  primaryColor;
  final Color  secondaryColor;
  final double  bgThickness;
  final double  sfThickness;
  final Curve   fillCurve;
  final Duration fillDuration;
  final bool showPercentOrChild;

  final Widget Function(double percent) childBuilder;


  RadialProgress({
    @required this.percent,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.grey,
    this.bgThickness = 4,
    this.sfThickness = 10,
    this.fillCurve = Curves.fastLinearToSlowEaseIn,
    this.fillDuration = const Duration(milliseconds: 1000),
    this.showPercentOrChild = false,
    this.childBuilder
  });

  @override
  _RadialProgressState createState() => _RadialProgressState();
}

class _RadialProgressState extends State<RadialProgress> with SingleTickerProviderStateMixin {
  AnimationController controller;
  double previousPercent;
  Animation<double> percentMovement;

  @override
  void dispose() { 
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() { 
    super.initState();
    
    previousPercent = widget.percent;

    controller = new AnimationController(
      vsync: this,
      duration: widget.fillDuration
    );

  }



  @override
  Widget build(BuildContext context) {

    percentMovement = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller, curve: widget.fillCurve
      )
    );

    controller.forward(from: 0);

    final diff = widget.percent - previousPercent;
    previousPercent = widget.percent;

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget child) {
        return Container(
          padding: EdgeInsets.all(10),
          width: double.infinity,
          height: double.infinity,
          child: widget.showPercentOrChild 
                  ? buildShowChildOrPercent(
                      diff,
                    ) 
                  : buildCustomPaint(diff),
        );
      },
    );
  }

  Stack buildShowChildOrPercent(double diff) {
    double value =  ((widget.percent - diff) + (diff * percentMovement.value));

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        buildCustomPaint(diff),
        widget.childBuilder == null 
        ? Center(
            child: Text('${value.toStringAsFixed(0)}%'),
          )
        : widget.childBuilder(value)
      ],
    );
  }

  CustomPaint buildCustomPaint(double diff) {
    return CustomPaint(
          painter: _RadialProgress(
            (widget.percent - diff) + (diff * percentMovement.value),
            widget.primaryColor,
            widget.secondaryColor,
            widget.bgThickness,
            widget.sfThickness
          ),
        );
  }
}

class _RadialProgress  extends CustomPainter{

  double percent;
  Color  primaryColor;
  Color  secondaryColor;
  double  bgThickness;
  double  sfThickness;


  _RadialProgress(
    this.percent,
    this.primaryColor,
    this.secondaryColor,
    this.bgThickness,
    this.sfThickness
  );

  @override
  void paint(Canvas canvas, Size size) {

    final paint             = new Paint()
          ..    strokeWidth = bgThickness
          ..    color       = secondaryColor
          ..    style       = PaintingStyle.stroke;

    Offset center = new Offset(size.width * 0.5, size.height / 2 );

    double radius = Math.min(size.width  * 0.5, size.height * 0.5);


    canvas.drawCircle(center, radius, paint);

    final paintArc            = new Paint()
          ..      strokeWidth = sfThickness
          ..      color       = primaryColor
          ..      strokeCap   = StrokeCap.round
          ..      style       = PaintingStyle.stroke;

    double arcAngle = 2 * Math.pi * (percent / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -Math.pi / 2,
      arcAngle,
      false,
      paintArc
    );



  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
