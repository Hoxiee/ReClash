#ifndef RECLASH_HOTKEY_CHANNEL_H
#define RECLASH_HOTKEY_CHANNEL_H

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>

#include "application_actions.h"

class HotkeyChannel {
 public:
  HotkeyChannel(GtkApplication* application, FlBinaryMessenger* messenger,
                GdkDisplay* display);
  ~HotkeyChannel();

  void reset_invocation();
  bool was_invoked() const;

 private:
  static void method_call(FlMethodChannel*, FlMethodCall* call, gpointer data);
  FlMethodResponse* handle_method(FlMethodCall* call);

  GtkApplication* application_;
  FlMethodChannel* channel_;
  ApplicationActions actions_;
  bool system_supported_ = false;
};

#endif
