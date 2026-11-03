import 'package:flutter/foundation.dart';
import 'package:reclash/common/common.dart';
import 'package:reclash/providers/providers.dart';
import 'package:riverpod/riverpod.dart';

import 'facts.dart';

/// Services users most often reach through a proxy, and so the ones an
/// "unblock" script or an ad blocker most often rewrites in `hosts`.
const serviceDomains = {
  'youtube.com',
  'youtu.be',
  'googlevideo.com',
  'ytimg.com',
  'ggpht.com',
  'discord.com',
  'discord.gg',
  'discordapp.com',
  'discordapp.net',
  'discord.media',
  'telegram.org',
  'telegram.me',
  't.me',
  'instagram.com',
  'cdninstagram.com',
  'facebook.com',
  'fbcdn.net',
  'whatsapp.com',
  'whatsapp.net',
  'x.com',
  'twitter.com',
  'twimg.com',
  'chatgpt.com',
  'openai.com',
  'claude.ai',
  'anthropic.com',
  'gemini.google.com',
  'linkedin.com',
  'spotify.com',
  'notion.so',
};

@immutable
final class RelevantDomains {
  const RelevantDomains({
    this.subscription = const {},
    this.test = const {},
    this.services = serviceDomains,
  });

  final Set<String> subscription;
  final Set<String> test;
  final Set<String> services;

  /// The role of [domain] or of the closest parent listed; ReClash's own
  /// domains win over services.
  DomainRole? roleOf(String domain) {
    var name = domain.trim().toLowerCase();
    if (name.endsWith('.')) name = name.substring(0, name.length - 1);
    while (name.isNotEmpty) {
      if (subscription.contains(name)) return DomainRole.subscription;
      if (test.contains(name)) return DomainRole.test;
      if (services.contains(name)) return DomainRole.service;
      final dot = name.indexOf('.');
      if (dot < 0) return null;
      name = name.substring(dot + 1);
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is RelevantDomains &&
      setEquals(other.subscription, subscription) &&
      setEquals(other.test, test) &&
      setEquals(other.services, services);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(subscription),
    Object.hashAllUnordered(test),
    Object.hashAllUnordered(services),
  );
}

final relevantDomainsProvider = Provider<RelevantDomains>((ref) {
  final testUrl = ref.watch(
    patchClashConfigProvider.select((config) => config.testUrl),
  );
  final subscription = ref.watch(
    profilesProvider.select(
      (profiles) => {
        for (final profile in profiles)
          if (profile.url.webUri?.host case final host? when host.isNotEmpty)
            host.toLowerCase(),
      },
    ),
  );
  return RelevantDomains(
    subscription: subscription,
    test: {
      for (final url in [testUrl, defaultTestUrl])
        if (url.webUri?.host case final host? when host.isNotEmpty)
          host.toLowerCase(),
    },
  );
});
