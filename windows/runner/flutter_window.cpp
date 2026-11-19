#include "flutter_window.h"

#include <flutter/encodable_value.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <optional>

#include <window/window_plugin_runner.h>

#include "flutter/generated_plugin_registrant.h"

namespace {
UINT MaintenanceMessage() {
  static const UINT message =
      ::RegisterWindowMessageW(L"ReClash.InstalledProductMaintenance");
  return message;
}

// Windows ends the process once WM_ENDSESSION returns and shows its "this app
// is preventing shutdown" screen after about five seconds.
constexpr ULONGLONG kEndSessionBudgetMs = 4500;
}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {

  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::RequestTerminate() {
  flutter::MethodChannel<flutter::EncodableValue> channel(
      flutter_controller_->engine()->messenger(), "window",
      &flutter::StandardMethodCodec::GetInstance());
  flutter::EncodableMap args;
  args[flutter::EncodableValue("name")] =
      flutter::EncodableValue("end-session");
  channel.InvokeMethod("onEvent",
                       std::make_unique<flutter::EncodableValue>(args));
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  if (flutter_controller_ && MaintenanceMessage() != 0 &&
      message == MaintenanceMessage()) {
    RequestTerminate();
    return 0;
  }

  // The quit path runs in Dart and answers through this thread's message
  // queue, so it is pumped here until the app exits or the budget runs out.
  if (flutter_controller_ && message == WM_ENDSESSION && wparam == TRUE) {
    RequestTerminate();
    const ULONGLONG deadline = ::GetTickCount64() + kEndSessionBudgetMs;
    MSG msg;
    while (flutter_controller_) {
      const ULONGLONG now = ::GetTickCount64();
      if (now >= deadline) {
        break;
      }
      ::MsgWaitForMultipleObjects(0, nullptr, FALSE,
                                  static_cast<DWORD>(deadline - now),
                                  QS_ALLINPUT);
      while (::PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
        if (msg.message == WM_QUIT) {
          ::PostQuitMessage(static_cast<int>(msg.wParam));
          return 0;
        }
        ::TranslateMessage(&msg);
        ::DispatchMessage(&msg);
      }
    }
    return 0;
  }

  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    WindowPluginForwardVisibility(*flutter_controller_, message, wparam,
                                  lparam);
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
