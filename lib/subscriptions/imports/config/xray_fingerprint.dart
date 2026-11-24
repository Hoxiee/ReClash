library;

const _mihomoFingerprints = {
  'chrome',
  'firefox',
  'safari',
  'ios',
  'android',
  'edge',
  '360',
  'qq',
  'random',
  'randomized',
  'chrome120',
  'firefox120',
  'safari16',
  'chrome_psk',
  'chrome_psk_shuffle',
  'chrome_padding_psk_shuffle',
  'chrome_pq',
  'chrome_pq_psk',
};

const _fingerprintFamilies = [
  ('hellochrome', 'chrome'),
  ('hellofirefox', 'firefox'),
  ('hellosafari', 'safari'),
  ('helloios', 'ios'),
  ('helloedge', 'edge'),
  ('hello360', '360'),
  ('helloqq', 'qq'),
  ('helloandroid', 'android'),
  ('hellorandomized', 'randomized'),
  ('randomized', 'randomized'),
];

// Xray reads an empty fingerprint as Chrome; mihomo reads it, and any name it
// does not know, as Go TLS. REALITY needs uTLS, so only plain TLS keeps opt-outs.
String? resolveClientFingerprint(String raw, {required bool reality}) {
  final name = raw.trim().toLowerCase();
  if (name.isEmpty) return 'chrome';
  if (name == 'unsafe' ||
      name == 'none' ||
      name == 'hellogolang' ||
      name == 'golang') {
    return reality ? 'chrome' : null;
  }
  if (name == 'randomizednoalpn') return 'randomized';
  if (_mihomoFingerprints.contains(name)) return name;
  if (name == 'hellochrome_120') return 'chrome120';
  if (name == 'hellofirefox_120') return 'firefox120';
  if (name == 'hellosafari_16_0') return 'safari16';
  for (final (prefix, target) in _fingerprintFamilies) {
    if (name.startsWith(prefix)) return target;
  }
  return 'chrome';
}

void applyClientFingerprint(Map<String, Object?> proxy, String raw) {
  final reality = proxy['reality-opts'];
  final fingerprint = resolveClientFingerprint(raw, reality: reality is Map);
  if (fingerprint == null) return;
  proxy['client-fingerprint'] = fingerprint;
  // mihomo strips X25519MLKEM768 from REALITY hellos unless this is set.
  if (fingerprint == 'chrome' && reality is Map<String, Object?>) {
    reality['support-x25519mlkem768'] = true;
  }
}
