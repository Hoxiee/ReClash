library;

class ExtensionEntry {
  const ExtensionEntry({
    required this.id,
    required this.name,
    required this.schemes,
  });

  final String id;
  final String name;
  final List<String> schemes;
}

const bundledExtensions = [
  ExtensionEntry(id: 'openflux', name: 'OpenFlux', schemes: ['openflux']),
];

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
  final hash = link.indexOf('#');
  var name = '';
  if (hash >= 0) {
    try {
      name = Uri.decodeComponent(link.substring(hash + 1)).trim();
    } on ArgumentError {
      name = link.substring(hash + 1).trim();
    }
  }
  return {
    'name': name.isEmpty ? '${extension.name} $count' : name,
    'type': 'extension',
    'extension': extension.id,
    'link': link,
  };
}
