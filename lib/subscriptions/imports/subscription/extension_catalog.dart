library;

class ExtensionEntry {
  const ExtensionEntry({
    required this.id,
    required this.name,
    required this.schemes,
    this.nameOf,
  });

  final String id;
  final String name;
  final List<String> schemes;
  final String Function(String link)? nameOf;
}

const bundledExtensions = [
  ExtensionEntry(id: 'openflux', name: 'OpenFlux', schemes: ['openflux']),
  ExtensionEntry(id: 'qwdtt', name: 'qWDTT', schemes: ['qwdtt']),
  ExtensionEntry(id: 'naive', name: 'NaiveProxy', schemes: ['naive+https']),
  ExtensionEntry(
    id: 'olcrtc',
    name: 'olcRTC',
    schemes: ['olcrtc'],
    nameOf: _olcrtcName,
  ),
];

/// olcRTC carries the key in the fragment; the name follows it after `$`.
String _olcrtcName(String link) {
  final hash = link.indexOf('#');
  final dollar = hash < 0 ? -1 : link.indexOf(r'$', hash);
  return dollar < 0 ? '' : _decodeName(link.substring(dollar + 1));
}

String _fragmentName(String link) {
  final hash = link.indexOf('#');
  return hash < 0 ? '' : _decodeName(link.substring(hash + 1));
}

String _decodeName(String value) {
  try {
    return Uri.decodeComponent(value).trim();
  } on ArgumentError {
    return value.trim();
  }
}

/// The protocol a node shows as its type: an extension node names the
/// protocol it runs instead of the generic `extension` type.
String proxyTypeLabel(String type, String? extension) {
  if (extension == null || extension.isEmpty) return type;
  for (final entry in bundledExtensions) {
    if (entry.id == extension) return entry.name;
  }
  return extension;
}

ExtensionEntry? extensionForScheme(String? scheme) {
  if (scheme == null) return null;
  for (final entry in bundledExtensions) {
    if (entry.schemes.contains(scheme)) return entry;
  }
  return null;
}

/// [count] numbers unnamed nodes of this extension within one import.
Map<String, Object?> extensionNode(
  ExtensionEntry extension,
  String link,
  int count,
) {
  final name = (extension.nameOf ?? _fragmentName)(link);
  return {
    'name': name.isEmpty ? '${extension.name} $count' : name,
    'type': 'extension',
    'extension': extension.id,
    'link': link,
  };
}
