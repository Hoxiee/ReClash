import 'dart:io';

class ReleaseVersion {
  ReleaseVersion._(this.name, this.buildNumber);

  factory ReleaseVersion.parse(String value) {
    final match = RegExp(
      r'^(\d+\.\d+\.\d+(?:-pre\.[1-9]\d*)?)\+(\d{10})$',
    ).firstMatch(value);
    if (match == null) {
      throw FormatException('Invalid release version: $value');
    }
    final build = match.group(2)!;
    final year = int.parse(build.substring(0, 4));
    final month = int.parse(build.substring(4, 6));
    final day = int.parse(build.substring(6, 8));
    final date = DateTime.utc(year, month, day);
    if (date.year != year ||
        date.month != month ||
        date.day != day ||
        int.parse(build.substring(8)) == 0 ||
        int.parse(build) + 4000 > 2100000000) {
      throw FormatException('Invalid release build number: $build');
    }
    return ReleaseVersion._(match.group(1)!, build);
  }

  factory ReleaseVersion.fromPubspec(String source) {
    final match = RegExp(
      r'^version:\s*(\S+)\s*$',
      multiLine: true,
    ).firstMatch(source);
    if (match == null) throw const FormatException('Missing pubspec version');
    return ReleaseVersion.parse(match.group(1)!);
  }

  static ReleaseVersion read(String root) =>
      ReleaseVersion.fromPubspec(File('$root/pubspec.yaml').readAsStringSync());

  final String name;
  final String buildNumber;

  String get base => name.split('-').first;
  String get linuxVersion => name.replaceFirst('-pre.', '~pre.');
  String get debianVersion => '1:$linuxVersion-$buildNumber';
  String get macosBuildNumber => [
    buildNumber.substring(2, 6),
    buildNumber.substring(6, 8),
    buildNumber.substring(8),
  ].map(int.parse).join('.');
}
