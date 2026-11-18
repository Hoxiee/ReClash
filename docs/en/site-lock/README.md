# Site lock

Site lock pins chosen sites to the exit servers you pick: their traffic leaves only through one of those servers or not at all, whatever the mode, rules or selected proxy. Everything else keeps its usual route.

## How a lock works

The core checks every new connection against the enabled locks before the mode and the rules. A connection that matches a lock goes to the first of its exit servers that passed its last delay check, or to the first one when all of them failed it. When the running profile has none of the lock's servers, the connection is refused. A locked site never goes DIRECT, not even in Direct mode.

An exit server is remembered by its type, address and port, not by its name, so renaming a server or refreshing a subscription keeps the lock. Proxy groups and the built-in DIRECT and REJECT never count as exits.

## Create a lock

Open **Tools → Advanced configuration → Site lock** and tap **+**.

- **Name** is optional; without one the list shows the first site.
- **Sites** takes one entry per line.
- **Except** takes entries that stay outside the lock even when they match **Sites**.
- **Exit servers** lists the servers of the running profile. A server that several names point at is one row. The list loads only while the core runs; saved servers stay in the lock either way.

| You type | Saved as |
| --- | --- |
| `chatgpt.com`, `*.chatgpt.com` or `.chatgpt.com` | `DOMAIN-SUFFIX,chatgpt.com` |
| `geosite:openai` | `GEOSITE,openai` |
| `1.2.3.4` | `IP-CIDR,1.2.3.4/32` |
| `2001:db8::/32` | `IP-CIDR6,2001:db8::/32` |
| A mihomo rule without its target, such as `DOMAIN,api.openai.com` or `DOMAIN-KEYWORD,openai` | As typed |

A lock holds up to 128 entries and 16 exit servers, and you can keep up to 32 locks. The core checks the whole list when you save it: if it rejects one entry, the previous locks stay in force and the page shows why.

## Status

| Status | Meaning |
| --- | --- |
| Through *server* | Locked connections leave through this server. |
| All exits are down | Every exit failed its last delay check; connections still try the first one. |
| No exit server in the profile | The running profile has none of the lock's servers, so locked connections are refused. |
| Off | The lock is disabled. |
| Waiting for the core | The core has not reported this lock yet. |

## Outside the tunnel on Linux

On Linux with TUN enabled and the Helper installed, the Helper also keeps the lock in the system firewall. Outside the TUN interface it rejects traffic to the locked addresses and the fake-ip range, and it drops DNS queries for the locked names. This holds while the core is stopped or has crashed, and the Helper restores it at boot before ReClash starts. To reach a locked site directly, turn its lock off.

> [!IMPORTANT]
> While a lock is enabled, every DNS query outside the tunnel passes through the Helper. If the Helper stops, those queries stop too instead of leaking.

A dropped DNS query is not answered, so an application waits for its own timeout before it gives up on a locked name.

## Limitations

- **Windows, macOS and Android** have the core layer only: once the core stops, nothing blocks the locked sites.
- **TUN off**: the lock covers only traffic that goes through the core, and the system firewall blocks nothing.
- **Sniffing off**: a connection whose name the core did not resolve itself arrives as a bare address and does not match domain entries. The page warns when this applies.
- **Core-only entries**: entries the system firewall cannot mirror, such as negated geosite attributes, regular expressions with lookaround, logic rules or port rules, are held only while the core runs. The page lists the locks that have them.
- **Encrypted DNS in browsers**: DNS over HTTPS and DNS over TLS bypass the Helper's DNS filter. While the core runs this does not matter, but after a crash such a browser can resolve and reach a locked site. Turn secure DNS off in the browser: in Chrome under **Settings → Privacy and security → Security → Use secure DNS**, in Firefox under **Settings → Privacy & Security → DNS over HTTPS**.
- **Hard-coded addresses**: an application that connects by an address it already knows is caught only by address entries. Add `IP-CIDR` entries for services that do this.
