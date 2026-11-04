abstract interface class NonceStore {
  Future<bool> isUsed(String nonce);

  /// Marks [nonce] used until [expires]; false when it already was.
  Future<bool> consume(String nonce, DateTime expires);
}

/// Used nonces as `<nonce> <expiry in unix seconds>` lines, dropped once their
/// link has expired, since an expired link fails before its nonce is looked
/// at.
class PersistedNonceStore implements NonceStore {
  PersistedNonceStore({
    required Future<List<String>> Function() load,
    required Future<void> Function(List<String> entries) save,
    DateTime Function()? clock,
  }) : _load = load,
       _save = save,
       _clock = clock ?? DateTime.now;

  final Future<List<String>> Function() _load;
  final Future<void> Function(List<String> entries) _save;
  final DateTime Function() _clock;
  Future<void> _queue = Future.value();

  Future<Map<String, int>> _read() async {
    final now = _clock().millisecondsSinceEpoch ~/ 1000;
    final used = <String, int>{};
    for (final line in await _load()) {
      final [nonce, expiry] = switch (line.split(' ')) {
        final parts when parts.length == 2 => parts,
        _ => const ['', ''],
      };
      final seconds = int.tryParse(expiry);
      if (nonce.isNotEmpty && seconds != null && seconds > now) {
        used[nonce] = seconds;
      }
    }
    return used;
  }

  Future<T> _serial<T>(Future<T> Function() task) {
    final result = _queue.then((_) => task());
    _queue = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  @override
  Future<bool> isUsed(String nonce) =>
      _serial(() async => (await _read()).containsKey(nonce));

  @override
  Future<bool> consume(String nonce, DateTime expires) => _serial(() async {
    final used = await _read();
    if (used.containsKey(nonce)) return false;
    used[nonce] = expires.millisecondsSinceEpoch ~/ 1000;
    await _save([
      for (final MapEntry(:key, :value) in used.entries) '$key $value',
    ]);
    return true;
  });
}
