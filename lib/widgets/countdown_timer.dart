import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime targetTime;
  final String prayerName;

  const CountdownTimer({
    super.key,
    required this.targetTime,
    required this.prayerName,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _timeRemaining;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.targetTime.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining = widget.targetTime.difference(DateTime.now());
      });
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeRemaining.isNegative) {
      return const Text(
        'Jamat is in progress',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    final hours = _timeRemaining.inHours;
    final minutes = _timeRemaining.inMinutes.remainder(60);
    final seconds = _timeRemaining.inSeconds.remainder(60);

    final isUrgent = _timeRemaining.inMinutes < 10;
    if (isUrgent && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isUrgent && _pulseController.isAnimating) {
      _pulseController.stop();
    }

    Widget textWidget = Text(
      'Next Jamat (${widget.prayerName.toUpperCase()}) in: '
      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: isUrgent ? Colors.redAccent.shade100 : Colors.white,
      ),
    );

    if (isUrgent) {
      return ScaleTransition(
        scale: Tween<double>(begin: 0.97, end: 1.03).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        ),
        child: textWidget,
      );
    }

    return textWidget;
  }
}
