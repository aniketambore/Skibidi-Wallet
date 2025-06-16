import 'package:bitwit_shit/services/breez_sdk_liquid.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';
import 'package:logging/logging.dart';

import 'input_state.dart';

final Logger _logger = Logger('InputCubit');

class InputCubit extends Cubit<InputState> {
  final BreezSDKLiquid _breezSdkLiquid;

  InputCubit(this._breezSdkLiquid) : super(const InputState.empty()) {
    // _initializeInputCubit();
  }

  Future<InputType> parseInput({required String input}) async {
    _logger.info('parseInput: $input');
    return await _breezSdkLiquid.instance!.parse(input: input);
  }
}
