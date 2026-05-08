import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MatchNote {
  final int matchId;
  final String text;
  final DateTime updatedAt;

  const MatchNote({
    required this.matchId,
    required this.text,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'matchId': matchId,
        'text': text,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory MatchNote.fromJson(Map json) => MatchNote(
        matchId: json['matchId'] as int,
        text: json['text'] as String? ?? '',
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class NotesNotifier extends StateNotifier<Map<int, MatchNote>> {
  NotesNotifier() : super({}) {
    _load();
  }

  static const _boxName = 'notes';

  void _load() {
    final box = Hive.box(_boxName);
    final result = <int, MatchNote>{};
    for (final key in box.keys) {
      final v = box.get(key);
      if (v is Map) {
        final note = MatchNote.fromJson(Map.from(v));
        result[note.matchId] = note;
      }
    }
    state = result;
  }

  MatchNote? forMatch(int matchId) => state[matchId];

  Future<void> save(int matchId, String text) async {
    final box = Hive.box(_boxName);
    if (text.trim().isEmpty) {
      await box.delete(matchId.toString());
    } else {
      final note = MatchNote(
        matchId: matchId,
        text: text.trim(),
        updatedAt: DateTime.now(),
      );
      await box.put(matchId.toString(), note.toJson());
    }
    _load();
  }

  Future<void> delete(int matchId) async {
    await Hive.box(_boxName).delete(matchId.toString());
    _load();
  }
}

final notesProvider =
    StateNotifierProvider<NotesNotifier, Map<int, MatchNote>>(
  (ref) => NotesNotifier(),
);
