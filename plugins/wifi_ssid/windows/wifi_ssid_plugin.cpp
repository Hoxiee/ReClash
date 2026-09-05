#include "wifi_ssid_plugin.h"

#include <windows.h>
#include <wlanapi.h>

#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <algorithm>
#include <memory>
#include <string>
#include <utility>

namespace wifi_ssid {

namespace {

constexpr int kPermissionGranted = 0;
constexpr char kChannelName[] = "wifi_ssid";
constexpr char kGetSsidMethod[] = "getSsid";
constexpr char kListSsidMethod[] = "listSsid";
// The scan reports stale results immediately and refreshes asynchronously.
constexpr DWORD kWlanScanWaitMs = 1200;
constexpr char kCheckPermissionMethod[] = "checkPermission";
constexpr char kRequestPermissionMethod[] = "requestPermission";

// Windows Server and any install without the Wireless LAN feature ships no
// wlanapi.dll, and a load-time import of it stops the whole app from starting.
struct WlanApi {
  decltype(&::WlanOpenHandle) open_handle = nullptr;
  decltype(&::WlanCloseHandle) close_handle = nullptr;
  decltype(&::WlanFreeMemory) free_memory = nullptr;
  decltype(&::WlanEnumInterfaces) enum_interfaces = nullptr;
  decltype(&::WlanQueryInterface) query_interface = nullptr;
  decltype(&::WlanScan) scan = nullptr;
  decltype(&::WlanGetAvailableNetworkList) get_network_list = nullptr;

  bool available() const { return open_handle != nullptr; }
};

const WlanApi &GetWlanApi() {
  static const WlanApi api = [] {
    WlanApi loaded;
    HMODULE module = LoadLibraryExW(L"wlanapi.dll", nullptr,
                                    LOAD_LIBRARY_SEARCH_SYSTEM32);
    if (module == nullptr) {
      return loaded;
    }
    loaded.open_handle = reinterpret_cast<decltype(loaded.open_handle)>(
        GetProcAddress(module, "WlanOpenHandle"));
    loaded.close_handle = reinterpret_cast<decltype(loaded.close_handle)>(
        GetProcAddress(module, "WlanCloseHandle"));
    loaded.free_memory = reinterpret_cast<decltype(loaded.free_memory)>(
        GetProcAddress(module, "WlanFreeMemory"));
    loaded.enum_interfaces = reinterpret_cast<decltype(loaded.enum_interfaces)>(
        GetProcAddress(module, "WlanEnumInterfaces"));
    loaded.query_interface = reinterpret_cast<decltype(loaded.query_interface)>(
        GetProcAddress(module, "WlanQueryInterface"));
    loaded.scan = reinterpret_cast<decltype(loaded.scan)>(
        GetProcAddress(module, "WlanScan"));
    loaded.get_network_list =
        reinterpret_cast<decltype(loaded.get_network_list)>(
            GetProcAddress(module, "WlanGetAvailableNetworkList"));
    if (loaded.close_handle == nullptr || loaded.free_memory == nullptr ||
        loaded.enum_interfaces == nullptr ||
        loaded.query_interface == nullptr || loaded.scan == nullptr ||
        loaded.get_network_list == nullptr) {
      return WlanApi{};
    }
    return loaded;
  }();
  return api;
}

struct WlanHandleDeleter {
  using pointer = HANDLE;

  void operator()(HANDLE handle) const {
    if (handle != nullptr) {
      GetWlanApi().close_handle(handle, nullptr);
    }
  }
};

struct WlanMemoryDeleter {
  template <typename T>
  void operator()(T *memory) const {
    if (memory != nullptr) {
      GetWlanApi().free_memory(memory);
    }
  }
};

using ScopedWlanHandle = std::unique_ptr<void, WlanHandleDeleter>;
using ScopedInterfaceList =
    std::unique_ptr<WLAN_INTERFACE_INFO_LIST, WlanMemoryDeleter>;
using ScopedConnectionAttributes =
    std::unique_ptr<WLAN_CONNECTION_ATTRIBUTES, WlanMemoryDeleter>;
using ScopedNetworkList =
    std::unique_ptr<WLAN_AVAILABLE_NETWORK_LIST, WlanMemoryDeleter>;

}  // namespace

void WifiSsidPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), kChannelName,
          &flutter::StandardMethodCodec::GetInstance());
  auto plugin = std::make_unique<WifiSsidPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });
  registrar->AddPlugin(std::move(plugin));
}

WifiSsidPlugin::WifiSsidPlugin() = default;

WifiSsidPlugin::~WifiSsidPlugin() = default;

void WifiSsidPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name() == kGetSsidMethod) {
    GetSsid(std::move(result));
  } else if (method_call.method_name() == kListSsidMethod) {
    ListSsid(std::move(result));
  } else if (method_call.method_name() == kCheckPermissionMethod ||
             method_call.method_name() == kRequestPermissionMethod) {
    result->Success(flutter::EncodableValue(kPermissionGranted));
  } else {
    result->NotImplemented();
  }
}

void WifiSsidPlugin::GetSsid(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const WlanApi &wlan = GetWlanApi();
  if (!wlan.available()) {
    result->Success(flutter::EncodableValue());
    return;
  }

  HANDLE client_handle = nullptr;
  DWORD current_version = 0;
  DWORD result_code = wlan.open_handle(WLAN_API_VERSION_2_0, nullptr,
                                       &current_version, &client_handle);
  if (result_code == ERROR_ACCESS_DENIED) {
    result->Success(flutter::EncodableValue());
    return;
  }
  if (result_code != ERROR_SUCCESS) {
    result->Error("WLAN_ERROR", "Failed to open WLAN handle",
                  flutter::EncodableValue(static_cast<int>(result_code)));
    return;
  }
  ScopedWlanHandle client(client_handle);

  PWLAN_INTERFACE_INFO_LIST interface_list = nullptr;
  result_code = wlan.enum_interfaces(client.get(), nullptr, &interface_list);
  if (result_code == ERROR_ACCESS_DENIED) {
    result->Success(flutter::EncodableValue());
    return;
  }
  if (result_code != ERROR_SUCCESS) {
    result->Error("WLAN_ERROR", "Failed to enumerate WLAN interfaces",
                  flutter::EncodableValue(static_cast<int>(result_code)));
    return;
  }
  ScopedInterfaceList interfaces(interface_list);

  std::string ssid;
  bool access_denied = false;
  for (DWORD i = 0; i < interfaces->dwNumberOfItems; ++i) {
    const auto &interface_info = interfaces->InterfaceInfo[i];
    if (interface_info.isState != wlan_interface_state_connected) {
      continue;
    }

    PWLAN_CONNECTION_ATTRIBUTES connection_attributes = nullptr;
    DWORD data_size = 0;
    result_code = wlan.query_interface(
        client.get(), &interface_info.InterfaceGuid,
        wlan_intf_opcode_current_connection, nullptr, &data_size,
        reinterpret_cast<PVOID *>(&connection_attributes), nullptr);

    if (result_code == ERROR_ACCESS_DENIED) {
      access_denied = true;
      break;
    }
    if (result_code != ERROR_SUCCESS || connection_attributes == nullptr) {
      continue;
    }

    ScopedConnectionAttributes connection(connection_attributes);
    const auto &dot11_ssid =
        connection->wlanAssociationAttributes.dot11Ssid;
    if (dot11_ssid.uSSIDLength == 0 ||
        dot11_ssid.uSSIDLength > DOT11_SSID_MAX_LENGTH) {
      continue;
    }
    ssid.assign(reinterpret_cast<const char *>(dot11_ssid.ucSSID),
                dot11_ssid.uSSIDLength);
    break;
  }

  if (access_denied || ssid.empty()) {
    result->Success(flutter::EncodableValue());
    return;
  }

  result->Success(flutter::EncodableValue(ssid));
}

void WifiSsidPlugin::ListSsid(
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const WlanApi &wlan = GetWlanApi();
  if (!wlan.available()) {
    result->Success(flutter::EncodableValue(flutter::EncodableList()));
    return;
  }

  HANDLE client_handle = nullptr;
  DWORD current_version = 0;
  DWORD result_code = wlan.open_handle(WLAN_API_VERSION_2_0, nullptr,
                                       &current_version, &client_handle);
  if (result_code != ERROR_SUCCESS) {
    result->Success(flutter::EncodableValue(flutter::EncodableList()));
    return;
  }
  ScopedWlanHandle client(client_handle);

  PWLAN_INTERFACE_INFO_LIST interface_list = nullptr;
  result_code = wlan.enum_interfaces(client.get(), nullptr, &interface_list);
  if (result_code != ERROR_SUCCESS) {
    result->Success(flutter::EncodableValue(flutter::EncodableList()));
    return;
  }
  ScopedInterfaceList interfaces(interface_list);

  // Scan results arrive asynchronously; a short wait lets a fresh scan land
  // while still returning the cached list when the wait does nothing.
  HANDLE event = CreateEventW(nullptr, TRUE, FALSE, nullptr);
  if (event == nullptr) {
    result->Success(flutter::EncodableValue(flutter::EncodableList()));
    return;
  }
  for (DWORD i = 0; i < interfaces->dwNumberOfItems; ++i) {
    const auto &interface_info = interfaces->InterfaceInfo[i];
    wlan.scan(client.get(), &interface_info.InterfaceGuid, nullptr, event,
              nullptr);
  }
  WaitForSingleObject(event, kWlanScanWaitMs);
  CloseHandle(event);

  flutter::EncodableList ssids;
  std::string current_ssid;
  for (DWORD i = 0; i < interfaces->dwNumberOfItems; ++i) {
    const auto &interface_info = interfaces->InterfaceInfo[i];
    if (interface_info.isState != wlan_interface_state_connected) {
      continue;
    }
    PWLAN_CONNECTION_ATTRIBUTES connection_attributes = nullptr;
    DWORD data_size = 0;
    result_code = wlan.query_interface(
        client.get(), &interface_info.InterfaceGuid,
        wlan_intf_opcode_current_connection, nullptr, &data_size,
        reinterpret_cast<PVOID *>(&connection_attributes), nullptr);
    if (result_code == ERROR_SUCCESS && connection_attributes != nullptr) {
      ScopedConnectionAttributes connection(connection_attributes);
      const auto &dot11_ssid =
          connection->wlanAssociationAttributes.dot11Ssid;
      if (dot11_ssid.uSSIDLength != 0 &&
          dot11_ssid.uSSIDLength <= DOT11_SSID_MAX_LENGTH) {
        current_ssid.assign(
            reinterpret_cast<const char *>(dot11_ssid.ucSSID),
            dot11_ssid.uSSIDLength);
      }
    }

    PWLAN_AVAILABLE_NETWORK_LIST network_list = nullptr;
    result_code = wlan.get_network_list(
        client.get(), &interface_info.InterfaceGuid, &network_list);
    if (result_code != ERROR_SUCCESS || network_list == nullptr) {
      continue;
    }
    ScopedNetworkList networks(network_list);
    for (DWORD j = 0; j < network_list->dwNumberOfItems; ++j) {
      const auto &network = network_list->Network[j];
      const auto &dot11_ssid = network.dot11Ssid;
      if (dot11_ssid.uSSIDLength == 0 ||
          dot11_ssid.uSSIDLength > DOT11_SSID_MAX_LENGTH) {
        continue;
      }
      std::string ssid(reinterpret_cast<const char *>(dot11_ssid.ucSSID),
                       dot11_ssid.uSSIDLength);
      const bool already = std::find(ssids.begin(), ssids.end(), ssid) !=
                           ssids.end();
      if (ssid == current_ssid) {
        if (already) {
          ssids.erase(std::find(ssids.begin(), ssids.end(), ssid));
        }
        ssids.insert(ssids.begin(), ssid);
      } else if (!already) {
        ssids.push_back(ssid);
      }
    }
  }

  result->Success(flutter::EncodableValue(ssids));
}

}  // namespace wifi_ssid
