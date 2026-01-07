import 'package:intl/intl.dart';

class SessionUpdateRequest {
  final String addSessionId;
  final List<SessionUpdateItem> sessions;

  SessionUpdateRequest({
    required this.addSessionId,
    required this.sessions,
  });

  Map<String, dynamic> toJson() => {
    "addSessionId": addSessionId,
    "sessions": sessions.map((e) => e.toJson()).toList(),
  };
}

class SessionUpdateItem {
  final int index;
  final DateTime dateTime;

  SessionUpdateItem({
    required this.index,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() => {
    "index": index,
    "date": DateFormat("yyyy-MM-dd").format(dateTime),
    "time": DateFormat("HH:mm").format(dateTime),
  };
}
