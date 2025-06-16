import 'dart:io';

import 'package:bitwit_shit/services/injector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_breez_liquid/flutter_breez_liquid.dart' as liquid_sdk;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import 'env.dart';

final Logger _logger = Logger('AppConfig');

class AppConfig {
  static AppConfig? _instance;

  final liquid_sdk.Config sdkConfig;

  AppConfig._({required this.sdkConfig});

  static Future<AppConfig> instance({ServiceInjector? serviceInjector}) async {
    _logger.info('Getting Config instance');
    if (_instance == null) {
      _logger.info('Creating Config instance');
      final liquid_sdk.Config defaultConf = _getDefaultConf();
      final liquid_sdk.Config sdkConfig = await getSDKConfig(defaultConf);

      _instance = AppConfig._(sdkConfig: sdkConfig);
    }
    return _instance!;
  }

  static liquid_sdk.Config _getDefaultConf({
    liquid_sdk.LiquidNetwork network = liquid_sdk.LiquidNetwork.mainnet,
  }) {
    _logger.info('Getting default SDK config for network: $network');
    // const String breezApiKey = String.fromEnvironment('API_KEY');
    const String breezApiKey = Env.breezApiKey;
    if (breezApiKey.isEmpty) {
      throw Exception('API_KEY is not set in environment variables');
    }
    return liquid_sdk.defaultConfig(network: network, breezApiKey: breezApiKey);
  }

  static Future<liquid_sdk.Config> getSDKConfig(
    liquid_sdk.Config defaultConf,
  ) async {
    _logger.info('Getting SDK config');
    return defaultConf.copyWith(workingDir: await _workingDir());
  }

  static Future<String> _workingDir() async {
    String path = '';
    if (defaultTargetPlatform == TargetPlatform.android) {
      final Directory workingDir = await getApplicationDocumentsDirectory();
      path = workingDir.path;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // TODO: Add iOS working dir
    }
    _logger.info('Using workingDir: $path');
    return path;
  }

  static String imageBaseUrl = Env.imageBaseUrl;
}

extension ConfigCopyWith on liquid_sdk.Config {
  liquid_sdk.Config copyWith({
    liquid_sdk.BlockchainExplorer? liquidExplorer,
    liquid_sdk.BlockchainExplorer? bitcoinExplorer,
    String? workingDir,
    liquid_sdk.LiquidNetwork? network,
    BigInt? paymentTimeoutSec,
    int? zeroConfMinFeeRateMsat,
    BigInt? zeroConfMaxAmountSat,
    String? breezApiKey,
    List<liquid_sdk.ExternalInputParser>? externalInputParsers,
    String? syncServiceUrl,
    List<liquid_sdk.AssetMetadata>? assetMetadata,
    String? sideswapApiKey,
  }) {
    return liquid_sdk.Config(
      liquidExplorer: liquidExplorer ?? this.liquidExplorer,
      bitcoinExplorer: bitcoinExplorer ?? this.bitcoinExplorer,
      workingDir: workingDir ?? this.workingDir,
      network: network ?? this.network,
      paymentTimeoutSec: paymentTimeoutSec ?? this.paymentTimeoutSec,
      zeroConfMaxAmountSat: zeroConfMaxAmountSat ?? this.zeroConfMaxAmountSat,
      breezApiKey: breezApiKey ?? this.breezApiKey,
      externalInputParsers: externalInputParsers ?? this.externalInputParsers,
      syncServiceUrl: syncServiceUrl ?? this.syncServiceUrl,
      useDefaultExternalInputParsers: true,
      assetMetadata: assetMetadata ?? this.assetMetadata,
      sideswapApiKey: sideswapApiKey ?? this.sideswapApiKey,
    );
  }
}
