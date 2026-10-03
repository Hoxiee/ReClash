#include "hotkey_channel.h"

#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include <cstring>
#include <limits>

HotkeyChannel::HotkeyChannel(GtkApplication* application,
                             FlBinaryMessenger* messenger, GdkDisplay* display)
    : application_(application),
      actions_(G_ACTION_MAP(application), [this](const char* name) {
        g_autoptr(FlValue) value = fl_value_new_string(name);
        fl_method_channel_invoke_method(channel_, "invoke", value, nullptr,
                                        nullptr, nullptr);
      }) {
#ifdef GDK_WINDOWING_X11
  const char* session = g_getenv("XDG_SESSION_TYPE");
  const char* wayland = g_getenv("WAYLAND_DISPLAY");
  const bool wayland_session = g_strcmp0(session, "wayland") == 0 ||
      (!session && wayland && *wayland);
  system_supported_ = GDK_IS_X11_DISPLAY(display) && !wayland_session;
#else
  (void)display;
#endif
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  channel_ = fl_method_channel_new(messenger, "com.reclash/hotkeys",
                                   FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel_, method_call, this, nullptr);
}

HotkeyChannel::~HotkeyChannel() {
  actions_.clear();
  fl_method_channel_set_method_call_handler(channel_, nullptr, nullptr, nullptr);
  g_clear_object(&channel_);
}

void HotkeyChannel::reset_invocation() {
  actions_.reset_invocation();
}

bool HotkeyChannel::was_invoked() const {
  return actions_.was_invoked();
}

FlMethodResponse* HotkeyChannel::handle_method(FlMethodCall* call) {
  const gchar* method = fl_method_call_get_name(call);
  FlValue* args = fl_method_call_get_args(call);
  if (strcmp(method, "initialize") == 0 &&
      fl_value_get_type(args) == FL_VALUE_TYPE_LIST) {
    std::vector<std::string> names;
    if (fl_value_get_length(args) <= 64) {
      for (size_t i = 0; i < fl_value_get_length(args); i++) {
        FlValue* name = fl_value_get_list_value(args, i);
        if (fl_value_get_type(name) != FL_VALUE_TYPE_STRING) {
          return FL_METHOD_RESPONSE(fl_method_error_response_new(
              "invalid_actions", "Invalid application actions", nullptr));
        }
        names.emplace_back(fl_value_get_string(name));
      }
      if (actions_.replace(names)) {
        g_autoptr(FlValue) result = fl_value_new_map();
        fl_value_set_string_take(
            result, "applicationId", fl_value_new_string(
                g_application_get_application_id(G_APPLICATION(application_))));
        fl_value_set_string_take(result, "systemSupported",
                                 fl_value_new_bool(system_supported_));
        return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
      }
    }
    return FL_METHOD_RESPONSE(fl_method_error_response_new(
        "invalid_actions", "Application actions conflict or are invalid", nullptr));
  }
  if (strcmp(method, "setEnabled") == 0 &&
      fl_value_get_type(args) == FL_VALUE_TYPE_BOOL) {
    actions_.set_enabled(fl_value_get_bool(args));
    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }
  if (strcmp(method, "keyNames") == 0 &&
      fl_value_get_type(args) == FL_VALUE_TYPE_LIST &&
      fl_value_get_length(args) <= 128) {
    g_autoptr(FlValue) result = fl_value_new_list();
    for (size_t i = 0; i < fl_value_get_length(args); i++) {
      FlValue* item = fl_value_get_list_value(args, i);
      const auto code = fl_value_get_type(item) == FL_VALUE_TYPE_INT
                            ? fl_value_get_int(item)
                            : 0;
      const gchar* name = nullptr;
      if (code > 0 && code <= std::numeric_limits<guint>::max() &&
          code != GDK_KEY_VoidSymbol) {
        name = gdk_keyval_name(static_cast<guint>(code));
      }
      fl_value_append_take(result, name && !g_str_has_prefix(name, "0x")
                                       ? fl_value_new_string(name)
                                       : fl_value_new_null());
    }
    return FL_METHOD_RESPONSE(fl_method_success_response_new(result));
  }
  if (strcmp(method, "dispose") == 0) {
    actions_.clear();
    return FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
  }
  return FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
}

void HotkeyChannel::method_call(FlMethodChannel*, FlMethodCall* call, gpointer data) {
  auto* self = static_cast<HotkeyChannel*>(data);
  g_autoptr(FlMethodResponse) response = self->handle_method(call);
  fl_method_call_respond(call, response, nullptr);
}
