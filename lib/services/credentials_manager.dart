import 'package:logging/logging.dart';

import 'keychain.dart';

final Logger _logger = Logger('CredentialsManager');

const String accountMnemonic = 'account_mnemonic';
const String accountApiKey = 'account_api_key';

class CredentialsManager {
  final KeyChain keyChain;

  CredentialsManager({required this.keyChain});

  Future<void> storeBreezApiKey({required String breezApiKey}) async {
    try {
      await _storeBreezApiKey(breezApiKey);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<String?> restoreBreezApiKey() async {
    try {
      final String? mnemonicStr = await keyChain.read(accountApiKey);
      return mnemonicStr;
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> deleteBreezApiKey() async {
    try {
      await keyChain.delete(accountApiKey);
      _logger.info('Deleted Breez API key successfully');
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> storeMnemonic({required String mnemonic}) async {
    try {
      await _storeMnemonic(mnemonic);
      _logger.info('Stored credentials successfully');
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<String?> restoreMnemonic() async {
    try {
      final String? mnemonicStr = await keyChain.read(accountMnemonic);
      _logger.info(
        (mnemonicStr != null)
            ? 'Restored credentials successfully'
            : 'No credentials found in secure storage',
      );
      return mnemonicStr;
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  Future<void> deleteMnemonic() async {
    try {
      await keyChain.delete(accountMnemonic);
      _logger.info('Deleted credentials successfully');
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  // Helper methods
  Future<void> _storeBreezApiKey(String breezApiKey) async {
    await keyChain.write(accountApiKey, breezApiKey);
  }

  Future<void> _storeMnemonic(String mnemonic) async {
    await keyChain.write(accountMnemonic, mnemonic);
  }
}
