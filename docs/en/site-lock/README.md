# Site lock

Site lock pins chosen sites to the exit servers you pick: their traffic leaves only through one of those servers or not at all, whatever the mode, rules or selected proxy. Everything else keeps its usual route.

## How a lock works

The core checks every new connection against the enabled locks before the mode and the rules. A connection that matches a lock goes to the first of its exit servers that passed its last delay check, or to the first one when all of them failed it. When the running profile has none of the lock's servers, the connection is refused. A locked site never goes DIRECT, not even in Direct mode.

An exit server is remembered by its whole definition except its name, so renaming a server keeps the lock, and servers that share one address but differ in credentials stay apart. When a subscription refresh changes the definition, the lock finds the server by its name instead, but only at the same address and port, so a server moved under its old name is not an exit and the lock refuses until you choose a server again. Proxy groups and the built-in DIRECT and REJECT never count as exits.

## Create a lock

Open **Tools → Advanced configuration → Site lock** and tap **+**.

- **Name** is optional; without one the list shows the first site.
- **Sites** takes one entry per line.
- **Except** takes entries that stay outside the lock even when they match **Sites**.
- **Exit servers** shows the chosen servers; **Choose servers** opens the servers of the running profile with a search by country or name. Identical servers under several names are one row. The list loads only while the core runs; saved servers stay in the lock either way, and a long press or right click removes one.

| You type | Saved as |
| --- | --- |
| `chatgpt.com`, `*.chatgpt.com` or `.chatgpt.com` | `DOMAIN-SUFFIX,chatgpt.com` |
| A pasted address such as `https://chatgpt.com/c/1` | `DOMAIN-SUFFIX,chatgpt.com` |
| `geosite:openai` | `GEOSITE,openai` |
| `1.2.3.4` | `IP-CIDR,1.2.3.4/32,no-resolve` |
| `2001:db8::/32` | `IP-CIDR6,2001:db8::/32,no-resolve` |
| A mihomo rule without its target, such as `DOMAIN,api.openai.com` or `DOMAIN-KEYWORD,openai` | As typed |

Domains in national scripts, such as `пример.рф`, also match their punycode form. An `IP-CIDR` entry typed without `no-resolve` makes the core resolve the name of every new connection to compare its address, which slows down connections that have nothing to do with the lock; keep `no-resolve` unless the lock must catch names that resolve into the range.

A lock holds up to 128 entries and 16 exit servers, and you can keep up to 32 locks. While the core runs, it checks the whole list when you save a lock: if it rejects an entry, the editor stays open and shows the entry and why, and the previous locks stay in force. A lock saved while the core is stopped is checked when the core starts; a lock it rejects then is shown with the reason and is not enforced.

## Presets

The page header has **From preset** with Claude, ChatGPT, Gemini, Grok, Perplexity, DeepSeek and Cursor. Picking one fills **Sites** with the service's geosite lists or domain suffixes and opens the editor so you can choose the exit servers. These services flag accounts whose IP address changes; the lock keeps them on the server you choose.

## Status

| Status | Meaning |
| --- | --- |
| Through *server* | Locked connections leave through this server. |
| All exits are down | Every exit failed its last delay check; connections still try the first one. |
| No exit server in the profile | The running profile has none of the lock's servers, so locked connections are refused. |
| Off | The lock is disabled. |
| Waiting for the core | The core has not reported this lock yet. |

## Outside the tunnel on Linux

On Linux with TUN enabled and the Helper installed, the Helper also keeps the lock in the system firewall. It needs the `nft` command (the `nftables` package); without it the page reports that the package is missing. ufw, firewalld and iptables keep working beside it: ReClash adds its own table `inet reclash_sitelock_<uid>` and does not change theirs. Locked addresses are rejected on every interface except the ReClash TUN, including the interface of another VPN. The fake-ip range is rejected only on physical interfaces, such as Ethernet and Wi-Fi, not on other tunnel interfaces (tun, WireGuard), so another VPN that hands out the same fake-ip range, as other mihomo-based clients do with `198.18.0.0/16`, can run in parallel. A DNS query for a locked name outside the ReClash TUN still goes into it or is dropped, so a parallel VPN cannot open a locked site. A DNS query for a locked name is not dropped: the Helper sends it into the tunnel, and the core answers with a fake address, so the name resolves and the connection leaves through the locked exit. Every other DNS query passes through untouched, so names known only to the home router or to another VPN keep resolving. While the core is stopped or has crashed there is no tunnel, so a query for a locked name is dropped and the block holds; the Helper also restores it at boot before ReClash starts. Exceptions by name apply here too; exceptions by address do not, so such an address stays blocked outside the tunnel. If something wipes the firewall, such as a firewall service restart, the Helper puts the lock back within about 10 seconds. To reach a locked site directly, turn its lock off. If the Helper is not running when you turn the last lock off, the firewall keeps blocking until the Helper is back; the page says so, and ReClash lifts the block as soon as the Helper responds.

> [!IMPORTANT]
> While a lock is enabled, every DNS query outside the tunnel passes through the Helper. If the Helper stops, those queries stop too instead of leaking.

To inspect the rules yourself, run `sudo nft list table inet reclash_sitelock_<uid>`, where `<uid>` is the output of `id -u`.

Only a query for a locked name over IPv4 and UDP goes into the tunnel. A query the Helper cannot read, such as a fragmented one, and a locked name asked over IPv6 or TCP, are dropped without an answer, so an application waits for its own timeout.

## Outside the tunnel on Windows

On Windows with TUN enabled and the Helper installed, the Helper keeps the lock in Windows Filtering Platform and in the DNS client's name resolution policy. Outside the TUN interface Windows rejects connections to the locked addresses on every interface but the TUN, and to the tunnel's DNS address. The fake-ip range is blocked only on Ethernet, Wi-Fi and PPP interfaces, so a parallel VPN works as on Linux. Locked names, both full names and suffixes, are resolved only by the tunnel's DNS, so the core answers with a fake address and the connection leaves through the locked exit; every other name resolves as before. While the core is stopped or has crashed there is no tunnel, so a locked name does not resolve and the block holds. The filters and rules persist across a reboot without the Helper. If something removes them, the Helper puts them back within about 10 seconds, and uninstalling the Helper lifts them. If the Helper is broken or was deleted without uninstalling, run `ReClashService.exe lift-site-lock` from the ReClash folder in an administrator terminal: it stops the Helper and removes the filters and rules, and it also lifts the [kill switch](kill-switch.md). Turning the last lock off behaves as on Linux.

Windows differs from Linux in three ways:

- **Keywords and regular expressions**: the name resolution policy matches only full names and suffixes, so `DOMAIN-KEYWORD`, `DOMAIN-REGEX` and `DOMAIN-WILDCARD` entries, and the keywords and expressions of a geosite list, are core-only.
- **Exceptions**: neither name nor address exceptions apply outside the tunnel, so an excepted name under a locked suffix does not resolve while the core is stopped.
- **Shared connections**: traffic Windows forwards for other devices, such as a mobile hotspot, is not filtered.

On a computer whose name resolution policy comes from domain Group Policy, the Helper adds its rules to that policy, and a policy refresh can remove them until the Helper restores them.

## System firewall on the page

On Linux and Windows the lock page shows a **System firewall** group with the **Mechanism** (nftables or Windows Filtering Platform), the **Status** (active or the problem), the **Blocked addresses**, the **Names filtered by DNS** and the **Fake-ip ranges kept off physical networks**. **Show rules** opens the live rules; on Linux it also shows the `nft` command to inspect them.

## Removing ReClash

> [!IMPORTANT]
> On Linux and Windows the system firewall enforces the lock through the Helper. It keeps working while ReClash is closed or has crashed, and from boot, and is lifted only by turning every lock off. DEB and RPM packages and the Windows uninstaller remove the Helper and its rules. For an AppImage or a manual install on Linux, use **Tools → Core → Remove Helper** first, or turn the locks off before deleting the app.

## On Android

Android has no firewall layer for the lock, but while a lock is on ReClash closes the gaps its own VPN would open:

- **No bypass**: apps cannot bypass the VPN, whatever **Tools → Network → Allow apps to bypass VPN** says. The setting keeps its value and applies again once every lock is off.
- **Routes**: the locked addresses and the profile's fake-ip ranges always go into the tunnel, even when **Route addresses** list only some networks or private networks are bypassed. With the default route list everything goes into the tunnel anyway.
- **Excluded apps**: apps that **Access control** leaves out of the VPN, or every app outside the list in "only selected apps" mode, reach locked sites without the lock. The page warns about them.
- **Kill switch**: Android only. The page shows whether Android's **Always-on VPN** with **Block connections without VPN** is on for ReClash and opens the system VPN settings. With it on, Android blocks traffic while the VPN is off, so locked sites stay unreachable when ReClash stops, but so does everything else, and apps excluded from the VPN may lose network access.

These options apply when the VPN starts. Turning a lock on or off, or changing its addresses, while the VPN runs offers a VPN restart, as other VPN settings do.

## Limitations

- **macOS** has the core layer only: once the core stops, nothing blocks the locked sites, and there is no kill switch.
- **Linux and Windows**: the desktop [kill switch](kill-switch.md) blocks all traffic outside the TUN, not only locked sites.
- **Android** adds only the VPN measures above: once the core stops, nothing but the system kill switch blocks the locked sites.
- **TUN off**: the lock covers only traffic that goes through the core, and the system firewall blocks nothing.
- **Sniffing**: domain entries match a connection by its name, and one whose name the core did not resolve itself, such as a browser using its own DNS, arrives as a bare address. While a lock with domain entries is on, the core therefore reads the name from TLS, HTTP and QUIC on their usual ports even when the profile has no sniffer; a profile that sets up its own sniffer keeps it. The name only picks the rule, so the connection still goes to the same address, but domain rules of the profile can now also catch such connections.
- **Encrypted Client Hello**: a browser that hides the site name with ECH, as Chrome and Firefox do for many Cloudflare sites, reveals only the provider's public name, so such a connection matches only address entries unless the core resolved the name itself.
- **Core-only entries**: entries the system firewall cannot mirror, such as negated geosite attributes, regular expressions with lookaround, logic rules or port rules, and on Windows keywords and regular expressions, are held only while the core runs. The page lists the locks that have them.
- **Provider-side changes**: the lock compares server definitions in the profile, not the address traffic finally leaves from. A provider that changes the exit IP behind the same server, or points a server's domain name at another machine, still satisfies the lock.
- **Unlisted domains**: a domain of the service that no entry covers follows the profile's rules. Presets cover the requests seen while building them; check which domains the service actually connects to and add the missing ones.
- **Encrypted DNS in browsers**: DNS over HTTPS and DNS over TLS bypass the Helper's DNS filter. While the core runs this does not matter, but after a crash such a browser can resolve and reach a locked site. Turn secure DNS off in the browser: in Chrome under **Settings → Privacy and security → Security → Use secure DNS**, in Firefox under **Settings → Privacy & Security → DNS over HTTPS**.
- **Hard-coded addresses**: an application that connects by an address it already knows is caught only by address entries. Add `IP-CIDR` entries for services that do this.
