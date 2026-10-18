#ifndef RECLASH_APPLICATION_ACTIONS_H
#define RECLASH_APPLICATION_ACTIONS_H

#include <gio/gio.h>

#include <functional>
#include <string>
#include <vector>

class ApplicationActions {
 public:
  using Invoke = std::function<void(const char*)>;

  ApplicationActions(GActionMap* application, Invoke invoke);
  ~ApplicationActions();

  bool replace(const std::vector<std::string>& names);
  void clear();
  void set_enabled(bool enabled);
  void reset_invocation();
  bool was_invoked() const;

 private:
  static void activate(GSimpleAction* action, GVariant*, gpointer data);

  GActionMap* application_;
  Invoke invoke_;
  std::vector<std::string> names_;
  bool enabled_ = true;
  bool invoked_ = false;
};

#endif
