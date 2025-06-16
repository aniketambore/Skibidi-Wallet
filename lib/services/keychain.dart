import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class KeyChain {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    // TODO: Add Keychain iOS Options
  );

  Future<String?> read(String key) {
    return _storage.read(key: key);
  }

  Future<void> write(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  Future<void> delete(String key) {
    return _storage.delete(key: key);
  }

  Future<void> clear() {
    return _storage.deleteAll();
  }
}
