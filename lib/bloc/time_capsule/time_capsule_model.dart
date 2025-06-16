import 'dart:convert';
import 'package:uuid/uuid.dart';

class TimeCapsule {
  final String id;
  final BigInt amountSat;
  final DateTime unlockDate;
  final String message;
  final DateTime createdAt;
  final bool isUnlocked;

  const TimeCapsule({
    required this.id,
    required this.amountSat,
    required this.unlockDate,
    required this.message,
    required this.createdAt,
    this.isUnlocked = false,
  });

  TimeCapsule copyWith({
    String? id,
    BigInt? amountSat,
    DateTime? unlockDate,
    String? message,
    DateTime? createdAt,
    bool? isUnlocked,
  }) {
    return TimeCapsule(
      id: id ?? this.id,
      amountSat: amountSat ?? this.amountSat,
      unlockDate: unlockDate ?? this.unlockDate,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountSat': amountSat.toString(),
      'unlockDate': unlockDate.toIso8601String(),
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  factory TimeCapsule.fromJson(Map<String, dynamic> json) {
    return TimeCapsule(
      id: json['id'] as String,
      amountSat: BigInt.parse(json['amountSat'] as String),
      unlockDate: DateTime.parse(json['unlockDate'] as String),
      message: json['message'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  factory TimeCapsule.create({
    required BigInt amountSat,
    required DateTime unlockDate,
    required String message,
  }) {
    return TimeCapsule(
      id: const Uuid().v4(),
      amountSat: amountSat,
      unlockDate: unlockDate,
      message: message,
      createdAt: DateTime.now(),
    );
  }

  bool get isExpired => DateTime.now().isAfter(unlockDate);

  @override
  String toString() => jsonEncode(toJson());
}
