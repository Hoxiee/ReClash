#include "application_actions.h"

#include <algorithm>
#include <set>
#include <utility>

ApplicationActions::ApplicationActions(GActionMap* application, Invoke invoke)
    : application_(application), invoke_(std::move(invoke)) {}

ApplicationActions::~ApplicationActions() {
  clear();
}

bool ApplicationActions::replace(const std::vector<std::string>& names) {
  if (names.size() > 64) return false;
  std::set<std::string> unique;
  for (const auto& name : names) {
    if (!g_action_name_is_valid(name.c_str()) ||
        !unique.insert(name).second) {
      return false;
    }
    const bool owned =
        std::find(names_.begin(), names_.end(), name) != names_.end();
    if (!owned && g_action_map_lookup_action(application_, name.c_str())) {
      return false;
    }
  }

  clear();
  names_ = names;
  enabled_ = true;
  for (const auto& name : names_) {
    g_autoptr(GSimpleAction) action = g_simple_action_new(name.c_str(), nullptr);
    g_signal_connect(action, "activate", G_CALLBACK(activate), this);
    g_action_map_add_action(application_, G_ACTION(action));
  }
  return true;
}

void ApplicationActions::clear() {
  for (const auto& name : names_) {
    g_action_map_remove_action(application_, name.c_str());
  }
  names_.clear();
}

void ApplicationActions::set_enabled(bool enabled) {
  enabled_ = enabled;
}

void ApplicationActions::reset_invocation() {
  invoked_ = false;
}

bool ApplicationActions::was_invoked() const {
  return invoked_;
}

void ApplicationActions::activate(GSimpleAction* action, GVariant*, gpointer data) {
  auto* self = static_cast<ApplicationActions*>(data);
  self->invoked_ = true;
  if (self->enabled_) {
    self->invoke_(g_action_get_name(G_ACTION(action)));
  }
}
