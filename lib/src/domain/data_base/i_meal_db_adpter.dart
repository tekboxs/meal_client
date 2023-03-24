abstract class IMealDBAdpter {
  ///will read data from storage with a key
  Future<dynamic> read(key, {bool ignoreCache = true});

  ///save value by key, void because should be sync
  void save(key, value);

  ///delete, used in removal of outdated keys
  void delete(key);
}
