import 'dart:async';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';
import '../account/account_cubit.dart';
import 'time_capsule_model.dart';
import 'time_capsule_state.dart';

final Logger _logger = Logger('TimeCapsuleCubit');

class TimeCapsuleCubit extends Cubit<TimeCapsuleState>
    with HydratedMixin<TimeCapsuleState> {
  final AccountCubit accountCubit;
  Timer? _expiryCheckTimer;

  TimeCapsuleCubit(this.accountCubit) : super(TimeCapsuleState.initial()) {
    hydrate();
    _startExpiryCheck();
  }

  void _startExpiryCheck() {
    // Check for expired capsules every minute
    _expiryCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      checkExpiredCapsules();
    });
  }

  @override
  Future<void> close() {
    _expiryCheckTimer?.cancel();
    return super.close();
  }

  Future<void> createCapsule({
    required BigInt amountSat,
    required DateTime unlockDate,
    required String message,
  }) async {
    try {
      // Validate amount
      if (amountSat <= BigInt.zero) {
        emit(state.copyWith(error: 'Amount must be greater than 0'));
        return;
      }

      // Validate unlock date
      if (unlockDate.isBefore(DateTime.now())) {
        emit(state.copyWith(error: 'Unlock date must be in the future'));
        return;
      }

      // Check if user has sufficient balance
      final currentBalance =
          accountCubit.state.walletInfo?.balanceSat ?? BigInt.zero;
      if (currentBalance < amountSat) {
        emit(state.copyWith(error: 'Insufficient balance'));
        return;
      }

      // Create new capsule
      final capsule = TimeCapsule.create(
        amountSat: amountSat,
        unlockDate: unlockDate,
        message: message,
      );

      // Update state
      final updatedCapsules = List<TimeCapsule>.from(state.capsules)
        ..add(capsule);
      emit(state.copyWith(capsules: updatedCapsules, error: null));

      _logger.info('Created new time capsule: ${capsule.id}');
    } catch (e, stack) {
      _logger.severe('Error creating time capsule: $e\n$stack');
      emit(state.copyWith(error: 'Failed to create time capsule'));
    }
  }

  Future<void> unlockCapsule(String id) async {
    try {
      final capsuleIndex = state.capsules.indexWhere((c) => c.id == id);
      if (capsuleIndex == -1) {
        emit(state.copyWith(error: 'Capsule not found'));
        return;
      }

      final capsule = state.capsules[capsuleIndex];
      if (!capsule.isExpired) {
        emit(state.copyWith(error: 'Capsule is not ready to be unlocked'));
        return;
      }

      if (capsule.isUnlocked) {
        emit(state.copyWith(error: 'Capsule is already unlocked'));
        return;
      }

      // Update capsule status
      final updatedCapsule = capsule.copyWith(isUnlocked: true);
      final updatedCapsules = List<TimeCapsule>.from(state.capsules)
        ..[capsuleIndex] = updatedCapsule;

      emit(state.copyWith(capsules: updatedCapsules, error: null));

      _logger.info('Unlocked time capsule: ${capsule.id}');
    } catch (e, stack) {
      _logger.severe('Error unlocking time capsule: $e\n$stack');
      emit(state.copyWith(error: 'Failed to unlock time capsule'));
    }
  }

  void checkExpiredCapsules() {
    try {
      final updatedCapsules =
          state.capsules.map((capsule) {
            if (capsule.isExpired && !capsule.isUnlocked) {
              _logger.info('Found expired capsule: ${capsule.id}');
              // You might want to trigger a notification here
              return capsule;
            }
            return capsule;
          }).toList();

      emit(state.copyWith(capsules: updatedCapsules));
    } catch (e, stack) {
      _logger.severe('Error checking expired capsules: $e\n$stack');
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  @override
  TimeCapsuleState? fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      _logger.severe('No stored data found.');
      return null;
    }

    try {
      final result = TimeCapsuleState.fromJson(json);
      _logger.fine('Successfully hydrated with $result');
      return result;
    } catch (e, stack) {
      _logger.severe('Error hydrating: $e\n$stack');
      return TimeCapsuleState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(TimeCapsuleState state) {
    try {
      final result = state.toJson();
      _logger.fine('Serialized: $result');
      return result;
    } catch (e) {
      _logger.severe('Error serializing: $e');
      return null;
    }
  }

  @override
  String get storagePrefix =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'lVt' : 'TimeCapsuleCubit';
}
