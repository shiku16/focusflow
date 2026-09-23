/// The supported study subjects, in display order.
const List<String> studySubjects = <String>[
  'Quantitative Aptitude',
  'Reasoning',
  'English',
  'General Awareness',
];

/// Formats a local calendar [date] as a stable `YYYY-MM-DD` identity key.
///
/// Task identity and persistence are based on local calendar dates, never on
/// timestamps, so a task created "today" can never be mistaken for a task on
/// another day.
String studyDateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// Parses a [studyDateKey]-formatted string back into a local date.
DateTime parseStudyDateKey(String value) {
  final List<String> parts = value.split('-');
  final int year = int.tryParse(parts[0]) ?? 1970;
  final int month = int.tryParse(parts[1]) ?? 1;
  final int day = int.tryParse(parts[2]) ?? 1;
  return DateTime(year, month, day);
}

/// The date of the Monday of the week containing [date].
DateTime mondayOfWeek(DateTime date) {
  return date.add(Duration(days: DateTime.monday - date.weekday));
}

/// A single study task for a specific local calendar date.
class StudyTask {
  /// Creates a study task.
  ///
  /// Throws an [ArgumentError] when the topic is empty, the subject is empty,
  /// or the duration is not positive.
  StudyTask({
    required this.id,
    required this.subject,
    required this.topic,
    required this.durationMinutes,
    required this.date,
    required this.completed,
  }) {
    if (topic.trim().isEmpty) {
      throw ArgumentError('Topic cannot be empty.');
    }
    if (durationMinutes <= 0) {
      throw ArgumentError('Duration must be greater than zero.');
    }
    if (subject.trim().isEmpty) {
      throw ArgumentError('Subject must be selected.');
    }
  }

  final String id;
  final String subject;
  final String topic;
  final int durationMinutes;
  final DateTime date;

  /// Whether the task has been completed.
  bool completed;

  /// Creates a copy with different [completed] state (and otherwise equal).
  StudyTask copyWith({required bool completed}) {
    return StudyTask(
      id: id,
      subject: subject,
      topic: topic,
      durationMinutes: durationMinutes,
      date: date,
      completed: completed,
    );
  }

  /// Serializes this task to a JSON-friendly map.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'subject': subject,
      'topic': topic,
      'durationMinutes': durationMinutes,
      'date': studyDateKey(date),
      'completed': completed,
    };
  }

  /// Deserializes a task from a JSON-friendly map produced by [toJson].
  static StudyTask fromJson(Map<String, Object?> json) {
    final int? minutes = (json['durationMinutes'] as num?)?.toInt();
    return StudyTask(
      id: (json['id'] as String?) ?? '',
      subject: (json['subject'] as String?) ?? '',
      topic: (json['topic'] as String?) ?? '',
      durationMinutes: minutes ?? 0,
      date: parseStudyDateKey((json['date'] as String?) ?? '1970-01-01'),
      completed: json['completed'] == true,
    );
  }
}
