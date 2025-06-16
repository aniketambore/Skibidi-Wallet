import 'package:flutter_breez_liquid/flutter_breez_liquid.dart';

import 'input_source.dart';

typedef TypeCheck = bool Function(InputType);

final List<TypeCheck> unsupportedInputTypeChecks = <TypeCheck>[
  (InputType input) => input is InputType_NodeId,
  (InputType input) => input is InputType_Url,
];

const Set<Type> unsupportedInputStates = <Type>{
  // NodeIdInputState,
  // UrlInputState,
};

class InputState {
  const InputState._();

  const factory InputState.empty() = EmptyInputState;

  const factory InputState.loading() = LoadingInputState;

  const factory InputState.invoice(LNInvoice invoice, InputSource source) =
      LnInvoiceInputState;
}

class EmptyInputState extends InputState {
  const EmptyInputState() : super._();

  @override
  String toString() {
    return 'EmptyInputState{}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmptyInputState && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class LoadingInputState extends InputState {
  const LoadingInputState() : super._();

  @override
  String toString() {
    return 'LoadingInputState{}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoadingInputState && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class LnInvoiceInputState extends InputState {
  const LnInvoiceInputState(this.lnInvoice, this.source) : super._();

  final LNInvoice lnInvoice;
  final InputSource source;

  @override
  String toString() {
    return 'LnInvoiceInputState{lnInvoice: $lnInvoice, source: $source}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LnInvoiceInputState &&
          runtimeType == other.runtimeType &&
          lnInvoice == other.lnInvoice &&
          source == other.source;

  @override
  int get hashCode => Object.hash(lnInvoice, source);
}
