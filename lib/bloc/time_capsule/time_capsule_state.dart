import 'dart:convert';
import 'package:logging/logging.dart';
import 'time_capsule_model.dart';

final Logger _logger = Logger('TimeCapsuleState');

class TimeCapsuleState {
  final List<TimeCapsule> capsules;
  final bool isLoading;
  final String? error;

  const TimeCapsuleState({
    this.capsules = const [],
    this.isLoading = false,
    this.error,
  });

  TimeCapsuleState copyWith({
    List<TimeCapsule>? capsules,
    bool? isLoading,
    String? error,
  }) {
    return TimeCapsuleState(
      capsules: capsules ?? this.capsules,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'capsules': capsules.map((capsule) => capsule.toJson()).toList(),
      'isLoading': isLoading,
    };
  }

  factory TimeCapsuleState.fromJson(Map<String, dynamic> json) {
    try {
      return TimeCapsuleState(
        capsules:
            (json['capsules'] as List<dynamic>)
                .map(
                  (capsuleJson) =>
                      TimeCapsule.fromJson(capsuleJson as Map<String, dynamic>),
                )
                .toList(),
        isLoading: json['isLoading'] as bool? ?? false,
      );
    } catch (e, stack) {
      _logger.severe('Error parsing TimeCapsuleState from JSON: $e\n$stack');
      return TimeCapsuleState.initial();
    }
  }

  factory TimeCapsuleState.initial() => const TimeCapsuleState();

  @override
  String toString() => jsonEncode(toJson());
}
