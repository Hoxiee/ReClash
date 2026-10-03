#include "application_actions.h"

#include <string>
#include <vector>

static void test_dispatch() {
  g_autoptr(GSimpleActionGroup) group = g_simple_action_group_new();
  std::vector<std::string> invoked;
  ApplicationActions actions(G_ACTION_MAP(group), [&](const char* name) {
    invoked.emplace_back(name);
  });
  g_assert_true(actions.replace({"toggle", "toggle-window", "mode-rule"}));
  g_action_group_activate_action(G_ACTION_GROUP(group), "toggle", nullptr);
  g_assert_cmpuint(invoked.size(), ==, 1);
  g_assert_cmpstr(invoked[0].c_str(), ==, "toggle");
  g_assert_true(actions.was_invoked());

  actions.reset_invocation();
  actions.set_enabled(false);
  g_action_group_activate_action(G_ACTION_GROUP(group), "mode-rule", nullptr);
  g_assert_cmpuint(invoked.size(), ==, 1);
  g_assert_true(actions.was_invoked());
  actions.set_enabled(true);
  g_action_group_activate_action(G_ACTION_GROUP(group), "mode-rule", nullptr);
  g_assert_cmpuint(invoked.size(), ==, 2);
}

static void test_replace_and_ownership() {
  g_autoptr(GSimpleActionGroup) group = g_simple_action_group_new();
  g_autoptr(GSimpleAction) external = g_simple_action_new("external", nullptr);
  g_action_map_add_action(G_ACTION_MAP(group), G_ACTION(external));
  {
    ApplicationActions actions(G_ACTION_MAP(group), [](const char*) {});
    g_assert_true(actions.replace({"toggle"}));
    g_assert_false(actions.replace({"invalid action"}));
    g_assert_false(actions.replace({"duplicate", "duplicate"}));
    g_assert_false(actions.replace({"external"}));
    g_assert_true(g_action_group_has_action(G_ACTION_GROUP(group), "toggle"));
    g_assert_true(actions.replace({"toggle-window"}));
    g_assert_false(g_action_group_has_action(G_ACTION_GROUP(group), "toggle"));
  }
  g_assert_false(g_action_group_has_action(G_ACTION_GROUP(group), "toggle-window"));
  g_assert_true(g_action_group_has_action(G_ACTION_GROUP(group), "external"));
}

struct RemoteCall {
  GMainLoop* loop;
  bool completed = false;
  bool success = false;
};

static void test_dbus_command() {
  g_autoptr(GTestDBus) bus = g_test_dbus_new(G_TEST_DBUS_NONE);
  g_test_dbus_up(bus);
  {
    g_autoptr(GApplication) application = g_application_new(
        "com.reclash.HotkeyTest", static_cast<GApplicationFlags>(0));
    g_autoptr(GError) error = nullptr;
    g_assert_true(g_application_register(application, nullptr, &error));
    g_assert_no_error(error);
    int invoked = 0;
    ApplicationActions actions(G_ACTION_MAP(application), [&](const char* name) {
      g_assert_cmpstr(name, ==, "toggle");
      invoked++;
    });
    g_assert_true(actions.replace({"toggle"}));
    g_autoptr(GMainLoop) loop = g_main_loop_new(nullptr, FALSE);
    RemoteCall call{loop};
    g_autoptr(GSubprocess) process = g_subprocess_new(
        G_SUBPROCESS_FLAGS_NONE, &error, "gapplication", "action",
        "com.reclash.HotkeyTest", "toggle", nullptr);
    g_assert_no_error(error);
    g_subprocess_wait_check_async(process, nullptr,
        [](GObject* object, GAsyncResult* result, gpointer data) {
          auto* state = static_cast<RemoteCall*>(data);
          state->success = g_subprocess_wait_check_finish(
              G_SUBPROCESS(object), result, nullptr);
          state->completed = true;
          g_main_loop_quit(state->loop);
        }, &call);
    const guint timeout = g_timeout_add_seconds(5, [](gpointer data) -> gboolean {
      g_main_loop_quit(static_cast<RemoteCall*>(data)->loop);
      return G_SOURCE_CONTINUE;
    }, &call);
    g_main_loop_run(loop);
    g_source_remove(timeout);
    if (!call.completed) g_subprocess_force_exit(process);
    g_assert_true(call.completed);
    g_assert_true(call.success);
    g_assert_cmpint(invoked, ==, 1);
    g_assert_true(actions.was_invoked());
  }
  g_test_dbus_down(bus);
}

int main(int argc, char** argv) {
  g_test_init(&argc, &argv, nullptr);
  g_test_add_func("/hotkeys/dispatch-and-suspend", test_dispatch);
  g_test_add_func("/hotkeys/replace-and-ownership", test_replace_and_ownership);
  g_test_add_func("/hotkeys/dbus-command", test_dbus_command);
  return g_test_run();
}
