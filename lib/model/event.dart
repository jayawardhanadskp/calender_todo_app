import 'package:flutter/material.dart';
import 'dart:ui';

// for events
class Event {
  final String title;
  final String description;
  final DateTime from;
  final DateTime to;
  final Color backgroundColor;
  final bool isAllDay;

  Event({
   required this.title,
   required this.description,
   required this.from,
   required this.to,
   this.backgroundColor = Colors.blue,
   this.isAllDay = false,

});
}

// for holidays
class Holiday {
  final String title;
  final DateTime date;

  Holiday({
    required this.title,
    required this.date,
});
}