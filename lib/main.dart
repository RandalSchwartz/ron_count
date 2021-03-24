import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: RonCount(),
    ),
  );
}

class RonCount extends HookWidget {
  const RonCount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultTextTheme = Theme.of(context).textTheme;
    final googleTextTheme =
        GoogleFonts.getTextTheme('Caveat Brush', defaultTextTheme);
    final ourTextTheme = googleTextTheme.apply(
      bodyColor: Colors.white,
      fontSizeFactor: 4.0,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF191033),
        textTheme: ourTextTheme,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends HookWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: MyPage()),
    );
  }
}

class MyPage extends HookWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tickerController =
        useAnimationController(duration: const Duration(days: 1000))..forward();
    useAnimation(tickerController);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CustomPaint(
          painter: StarPainter(),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Marquis(),
          )),
          size: constraints.biggest,
        );
      },
    );
  }
}

class Marquis extends HookWidget {
  Marquis({Key? key}) : super(key: key);

  final bye = DateTime.utc(2021, 6, 16, 15 + 7, 10); // June 16 at 3:10pm UTC-7

  @override
  Widget build(BuildContext context) {
    String s(num n, String text) {
      return '$n $text${n != 1 ? 's' : ''}';
    }

    final until = bye.difference(DateTime.now());
    final t = ((until.inSeconds / 5).floor() * 5).clamp(0, double.infinity);
    final secs = t % 60;
    final mins = (t ~/ 60) % 60;
    final hours = (t ~/ 3600) % 24;
    final days = t ~/ 86400;
    var parts = [
      if (days > 0) s(days, 'day'),
      if (hours > 0) s(hours, 'hour'),
      if (mins > 0) s(mins, 'minute'),
      if (secs > 0) s(secs, 'second'),
    ];
    if (parts.isEmpty) {
      return const Text(
        'Ron has retired!',
        textAlign: TextAlign.center,
      );
    }
    var say = '';

    // parts = 'A B C D'.split(' '); // for testing
    var serial = false;
    while (parts.length > 2) {
      say += parts.removeAt(0) + ', ';
      serial = true; // serial comma is needed; comment out if unwanted
    }
    if (parts.length > 1) {
      say += parts.removeAt(0) + (serial ? ', and ' : ' and ');
    }
    say += parts.removeAt(0); // now empty

    return Text(
      'Ron has $say until retirement!' // '\n${ticksecs.toStringAsFixed(2)}'
      ,
      textAlign: TextAlign.center,
    );
  }
}

final stars = <Star>{};

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();

    if (roll() < 0.03) {
      var star = Star.randomRightSide(now);
      stars.add(star);
    }

    var backgroundPaint = Paint()..color = const Color(0xFF191033);
    canvas.drawPaint(backgroundPaint);

    var starPaint = Paint()..color = (const Color(0xFFFFFF00));
    for (var s in {...stars}) {
      // clone stars so we can modify original in loop
      var currentAlign = s.alignmentAt(now);

      // still alive if on playfield:
      if (currentAlign.x.abs() <= 1.1 && currentAlign.y.abs() <= 1.1) {
        var currentOffset = currentAlign.alongSize(size);

        canvas.drawCircle(currentOffset, s.size, starPaint);
        // canvas.drawCircle(currentPos, s.size / size.width, starPaint);
      } else {
        stars.remove(s);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

double roll([double by = 1]) => Random().nextDouble() * by;

class Star {
  Star.randomRightSide(this.birthTime)
      : birthAlignment =
            Alignment(1.05, roll(2) - 1), // just off right wall somewhere
        speed = Alignment(-(roll(0.01) + 0.05), (roll() - 0.5) / 20), // leftish
        size = roll(3) + 1 // by experimentation
  ;

  /// right wall point (usually)
  final Alignment birthAlignment;

  /// time when born
  final DateTime birthTime;

  /// size in screen pixels
  final double size;

  /// delta alignment per tick
  final Alignment speed;

  @override
  String toString() =>
      'Star(birthOffset: ${birthAlignment.toMyString}, speed: ${speed.toMyString}, '
      'size: ${size.toStringAsFixed(2)}, birthSecs: $birthTime)';

  Alignment alignmentAt(DateTime now) {
    return birthAlignment +
        speed * (now.difference(birthTime).inMilliseconds / 1000.0);
  }
}

extension MyAlignment on Alignment {
  String get toMyString => 'Alignment(${x.toStringAsFixed(3)}, '
      '${y.toStringAsFixed(3)})';
}
