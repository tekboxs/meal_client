abstract class IMealDBAdpter {
  ///will read data from storage with a key
  Future<dynamic> read(key, {bool ignoreCache = true});

  ///save value by key, void because should be sync
  save(key, value);

  ///delete, used in removal of outdated keys
  delete(key);
}
