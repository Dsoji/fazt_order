import 'dart:collection' show MapView;

import 'package:flutter/foundation.dart' show immutable;

@immutable
class SchedulePayload extends MapView<String, dynamic> {
  SchedulePayload({
    Map<String, dynamic>? schedule,
  }) : super({
          'schedule': schedule ?? _emptyScheduleTemplate, // 👈 WRAP IT
        });

  static const Map<String, dynamic> _emptyScheduleTemplate = {
    "Monday": {
      "open": false,
      "time": [],
    },
    "Tuesday": {
      "open": false,
      "time": [],
    },
    "Wednesday": {
      "open": false,
      "time": [],
    },
    "Thursday": {
      "open": false,
      "time": [],
    },
    "Friday": {
      "open": false,
      "time": [],
    },
    "Saturday": {
      "open": false,
      "time": [],
    },
    "Sunday": {
      "open": false,
      "time": [],
    },
  };
}
