import 'dart:convert';
import 'dart:io';

import 'package:reclash/models/models.dart';

const subscriptionReportDecoderBase = 'https://hoxiee.github.io/ReClash-site';

String encodeSubscriptionReportBlob(SubscriptionReport report) {
  final payload = jsonEncode(report.toJson());
  final packed = gzip.encode(utf8.encode(payload));
  final b64 = base64Url.encode(packed).replaceAll('=', '');
  return 'R1.$b64'; // envelope report.js splits on '.', gunzips, JSON.parses
}

String subscriptionReportDecoderUrl(String blob, {required String lang}) {
  final decoderLang = lang == 'ru' ? 'ru' : 'en';
  return '$subscriptionReportDecoderBase/$decoderLang/report.html#d=$blob';
}
