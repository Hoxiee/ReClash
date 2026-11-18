# Site lock

Site lock pins chosen sites to the exit servers you pick: their traffic leaves only through one of those servers or not at all, whatever the mode, rules or selected proxy. Everything else keeps its usual route.

## How a lock works

The core checks every new connection against the enabled locks before the mode and the rules. A connection that matches a lock goes to the first of its exit servers that passed its last delay check, or to the first one when all of them failed it. When the running profile has none of the lock's servers, the connection is refused. A locked site never goes DIRECT, not even in Direct mode.

An exit server is remembered by its whole definition except its name, so renaming a server keeps the lock, and servers that share one address but differ in credentials stay apart. When a subscription refresh changes the definition, the lock finds the server by its name instead. Proxy groups and the built-in DIRECT and REJECT never count as exits.

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

## Status

| Status | Meaning |
| --- | --- |
| Through *server* | Locked connections leave through this server. |
| All exits are down | Every exit failed its last delay check; connections still try the first one. |
| No exit server in the profile | The running profile has none of the lock's servers, so locked connections are refused. |
| Off | The lock is disabled. |
| Waiting for the core | The core has not reported this lock yet. |

## Outside the tunnel on Linux

On Linux with TUN enabled and the Helper installed, the Helper also keeps the lock in the system firewall. Outside the TUN interface it rejects traffic to the locked addresses and the fake-ip range. A DNS query for a locked name is not dropped: the Helper sends it into the tunnel, and the core answers with a fake address, so the name resolves and the connection leaves through the locked exit. Every other DNS query passes through untouched, so names known only to the home router or to another VPN keep resolving. While the core is stopped or has crashed there is no tunnel, so a query for a locked name is dropped and the block holds; the Helper also restores it at boot before ReClash starts. Exceptions by name apply here too; exceptions by address do not, so such an address stays blocked outside the tunnel. If something wipes the firewall, such as a firewall service restart, the Helper puts the lock back within about 10 seconds. To reach a locked site directly, turn its lock off. If the Helper is not running when you turn the last lock off, the firewall keeps blocking until the Helper is back; the page says so, and ReClash lifts the block as soon as the Helper responds.

> [!IMPORTANT]
> While a lock is enabled, every DNS query outside the tunnel passes through the Helper. If the Helper stops, those queries stop too instead of leaking.

Only a query for a locked name over IPv4 and UDP goes into the tunnel. A query the Helper cannot read, such as a fragmented one, and a locked name asked over IPv6 or TCP, are dropped without an answer, so an application waits for its own timeout.

## Limitations

- **Windows, macOS and Android** have the core layer only: once the core stops, nothing blocks the locked sites.
- **TUN off**: the lock covers only traffic that goes through the core, and the system firewall blocks nothing.
- **Sniffing**: domain entries match a connection by its name, and one whose name the core did not resolve itself, such as a browser using its own DNS, arrives as a bare address. While a lock with domain entries is on, the core therefore reads the name from TLS, HTTP and QUIC on their usual ports even when the profile has no sniffer; a profile that sets up its own sniffer keeps it. The name only picks the rule, so the connection still goes to the same address, but domain rules of the profile can now also catch such connections.
- **Encrypted Client Hello**: a browser that hides the site name with ECH, as Chrome and Firefox do for many Cloudflare sites, reveals only the provider's public name, so such a connection matches only address entries unless the core resolved the name itself.
- **Core-only entries**: entries the system firewall cannot mirror, such as negated geosite attributes, regular expressions with lookaround, logic rules or port rules, are held only while the core runs. The page lists the locks that have them.
- **Encrypted DNS in browsers**: DNS over HTTPS and DNS over TLS bypass the Helper's DNS filter. While the core runs this does not matter, but after a crash such a browser can resolve and reach a locked site. Turn secure DNS off in the browser: in Chrome under **Settings → Privacy and security → Security → Use secure DNS**, in Firefox under **Settings → Privacy & Security → DNS over HTTPS**.
- **Hard-coded addresses**: an application that connects by an address it already knows is caught only by address entries. Add `IP-CIDR` entries for services that do this.
