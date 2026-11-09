{{flutter_js}}
{{flutter_build_config}}

// Missing glyphs are looked up here, never on fonts.gstatic.com.
_flutter.loader.load({
  config: {
    fontFallbackBaseUrl: new URL('fonts/fallback/', document.baseURI).href,
    // Hosts without cross-origin isolation run skwasm on one thread.
    suppressMultithreadingWarning: true,
  },
});
