import 'package:shared_preferences/shared_preferences.dart';

/// Minimal persistence boundary for FocusFlow app data.
///
/// Exposes only the small set of typed primitives the app state needs, so the
/// rest of the app never touches a storage API directly and tests can swap in
/// an in-memory implementation.
abstract class FocusFlowPersistence {
  Future<bool?> readBool(String key);

  Future<int?> readInt(String key);

  Future<String?> readString(String key);

  Future<void> writeBool(String key, bool value);

  Future<void> writeInt(String key, int value);

  Future<void> writeString(String key, String value);

  Future<void> remove(String key);
}

/// Production persistence backed by `shared_preferences`.
///
/// Uses the asynchronous API recommended by the package, which stores data in
/// the platform's local preferences store (e.g. Android DataStore).
class SharedPreferencesPersistence implements FocusFlowPersistence {
  SharedPreferencesPersistence() : _preferences = SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<bool?> readBool(String key) => _preferences.getBool(key);

  @override
  Future<int?> readInt(String key) => _preferences.getInt(key);

  @override
  Future<String?> readString(String key) => _preferences.getString(key);

  @override
  Future<void> writeBool(String key, bool value) =>
      _preferences.setBool(key, value);

  @override
  Future<void> writeInt(String key, int value) =>
      _preferences.setInt(key, value);

  @override
  Future<void> writeString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> remove(String key) => _preferences.remove(key);
}

/// In-memory persistence for tests (and safe non-persistent previews).
///
/// Mutations are applied synchronously, so tests can read what they just
/// wrote without racing the underlying async plumbing.
class InMemoryPersistence implements FocusFlowPersistence {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  Future<bool?> readBool(String key) => Future.value(_values[key] as bool?);

  @override
  Future<int?> readInt(String key) => Future.value(_values[key] as int?);

  @override
  Future<String?> readString(String key) =>
      Future.value(_values[key] as String?);

  @override
  Future<void> writeBool(String key, bool value) {
    _values[key] = value;
    return Future<void>.value();
  }

  @override
  Future<void> writeInt(String key, int value) {
    _values[key] = value;
    return Future<void>.value();
  }

  @override
  Future<void> writeString(String key, String value) {
    _values[key] = value;
    return Future<void>.value();
  }

  @override
  Future<void> remove(String key) {
    _values.remove(key);
    return Future<void>.value();
  }
}
