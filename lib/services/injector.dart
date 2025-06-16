import 'package:shared_preferences/shared_preferences.dart';

import 'breez_logger.dart';
import 'breez_preferences.dart';
import 'breez_sdk_liquid.dart';
import 'credentials_manager.dart';
import 'keychain.dart';

class ServiceInjector {
  static final ServiceInjector _singleton = ServiceInjector._internal();
  static ServiceInjector? _injector;

  BreezSDKLiquid? _breezSdkLiquid;
  Future<SharedPreferences>? _sharedPreferences =
      SharedPreferences.getInstance();
  KeyChain? _keychain;
  CredentialsManager? _credentialsManager;
  BreezPreferences? _breezPreferences;
  BreezLogger? _breezLogger;

  factory ServiceInjector() => _injector ?? _singleton;

  ServiceInjector._internal();

  static void configure(ServiceInjector injector) => _injector = injector;

  Future<SharedPreferences> get sharedPreferences =>
      _sharedPreferences ??= SharedPreferences.getInstance();

  KeyChain get keychain => _keychain ??= KeyChain();

  CredentialsManager get credentialsManager =>
      _credentialsManager ??= CredentialsManager(keyChain: keychain);

  BreezPreferences get breezPreferences =>
      _breezPreferences ??= BreezPreferences();

  BreezLogger get breezLogger => _breezLogger ??= BreezLogger();

  BreezSDKLiquid get breezSdkLiquid => _breezSdkLiquid ??= BreezSDKLiquid();
}
