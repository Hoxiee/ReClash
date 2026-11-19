# Kill switch

The desktop kill switch blocks all traffic outside ReClash's TUN, so nothing leaks if the tunnel drops. It exists on Linux and Windows and needs TUN and the Helper.

macOS has no kill switch. Android uses the system Always-on VPN with **Block connections without VPN**; see [On Android](README.md#on-android).

## Where to find it

Open **Tools → Network** and find the **Kill switch** section. The same control is on the [site lock](README.md) page. Its status reads **Waiting for TUN**, **Armed** or **Blocking**.

## What it blocks

The block is strict. While the kill switch is armed, all traffic outside ReClash's TUN is blocked, including addresses the TUN excludes, such as route exclusions and bypassed private networks. Allowed outside the TUN:

- loopback;
- the Core itself, so it can reach its servers;
- DHCP and link-local traffic;
- the local network, while **Allow local network** is on (the default).

> [!WARNING]
> Another VPN running in parallel loses internet too while the kill switch is armed.

## When it is armed

In the standard mode the kill switch arms on every Core start and when TUN is turned on. It stays armed through a crash, a Core restart, recovery and the relaunch after an app update. It is lifted when you stop deliberately: turn the proxy off, turn TUN off, or quit ReClash normally. A reboot lifts it too.

A stop through a URL scheme link or the diagnostics stop action does not lift it; use **Unblock**.

**Also block while ReClash is stopped** is the always mode. The computer then has no internet whenever ReClash's TUN is not running, including after ReClash is removed, unless you remove the Helper first. Turning it on asks for confirmation.

## The dashboard notice

When the kill switch blocks and no TUN is running, the dashboard shows **Kill switch is blocking the internet** with **Start** and, in the standard mode, **Unblock**.

## On Linux

The Helper keeps the rules in its own nftables table `inet reclash_killswitch_<uid>`, where `<uid>` is the output of `id -u`. It needs the `nftables` package. Inspect the table with:

```sh
sudo nft list table inet reclash_killswitch_<uid>
```

A restarted Helper restores the table before ReClash connects to it; after a reboot only the always mode blocks from boot. If something wipes the firewall, the Helper applies the table again within about 10 seconds.

In an emergency use **Tools → Core → Remove Helper**, or turn the kill switch off in the settings.

## On Windows

The kill switch is a set of persistent Windows Filtering Platform filters under ReClash's own provider. In an emergency run `ReClashService.exe lift-site-lock` from the ReClash folder in an administrator terminal: it stops the Helper and removes the site lock and kill switch filters.
