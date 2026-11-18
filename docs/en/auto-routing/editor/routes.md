# Route editor

The route editor and its pickers: traffic, server order, steps, countries and conditions.

## Traffic

**Add route** opens **New route** directly with the traffic picker first; there is no separate picking step. The **Name** fills from the picked service until you type your own. **Save** stays disabled without traffic and a name.

| Part | Content |
| --- | --- |
| **Services** | Chips for 19 services, each with one or more rules: YouTube (`GEOSITE,youtube`), Google, Gemini (`GEOSITE,google-gemini`), ChatGPT (`GEOSITE,openai`), Claude (`GEOSITE,anthropic`), Telegram (also `GEOIP,telegram,no-resolve`), Discord, WhatsApp, Instagram, Facebook, X (`GEOSITE,twitter`), TikTok, Netflix, Spotify, Twitch, Steam, GitHub, Apple, Microsoft. **All services** selects every chip. |
| **Custom** | **Add entry**: **Type**, **Value** and, for IP types, **Don’t resolve domains**. Shown with **Advanced settings** on, or when the route already has custom entries; **Add entry** needs **Advanced settings**. |

| Type | Rule |
| --- | --- |
| **Domain and subdomains** | `DOMAIN-SUFFIX` |
| **Domain** | `DOMAIN` |
| **Domain keyword** | `DOMAIN-KEYWORD` |
| **Site category** | `GEOSITE` |
| **IP category** | `GEOIP` |
| **IP range** | `IP-CIDR`, or `IP-CIDR6` when the value has a colon |
| **App** | `PROCESS-NAME` |
| **Rule set** | `RULE-SET` |

A malformed value shows **Invalid value**. Other match types are written in YAML; see [Match types](../scenarios.md#match-types).

## Route editor

The same page edits a route, **Everything else** and a subscription group program; the last two have no name or traffic.

| Row | Content |
| --- | --- |
| **Name** | Route and group name. **The name is too long** past 64 bytes; **This name is reserved** for reserved names; an error if a route or group already has it. |
| Traffic | First on a route: the picker above ("No traffic chosen" until something is picked). |
| **Where it goes** | **Best server**: the route's own group picks. **One server**: `to` a server or group chosen under **Choose**. **Direct**: `to: DIRECT`, routes only. |
| **How to pick the server** | The same block as the [group sheet](groups.md#how-the-group-picks): **Behaviour** (for a group, **As set on the group** keeps its own), **Server order** (`prefer`, see [Server order](#server-order)) and **Servers** (`pool.include`, `pool.exclude` through the [condition builder](#conditions); routes have only **Leave out servers**). |

For a group, **One server** holds the group on a member with no search (`to`); **Every group** does not offer it. Field errors show beside the field, others in a banner; saving is disabled while any remain. Delete removes the route; its traffic falls to the next match.

## Server order

Steps make up the server order: the first step with a working server decides; see [Tiers](../profiles.md#tiers).

| Part | Meaning |
| --- | --- |
| **Add a step** | Adds a step. The sort action reorders; the context menu deletes. |
| Empty list | **Any working server**: no order of its own. |
| Muted steps | "From the behaviour — edit a step to make the order your own": editing copies them first. |
| Connector | "if none of them works" between steps. |

### Steps

**Servers in this step** builds one condition; every row must hold.

| Row | Condition |
| --- | --- |
| **Name contains** | `name ~ /text/i`, the text taken literally |
| **Country** | `country in [..]`; with **All but these countries**, `not country in [..]` |
| **Add condition** → Provider, Protocol, Tag, Supports UDP, **Latency under, ms** | `provider =`, `type =`, `tag()`, `udp`, `latency <` |
| **Add condition** → **Advanced condition…** | Any condition, through the [condition builder](#conditions) |
| **Other conditions** | A part the rows cannot show, edited as text |

The footer counts the servers that fit now, when the condition can be tested locally. **Label** names the step; **Fallback** sets `last-resort`.

With **Advanced settings** off, **Add condition**, **Advanced condition…** and **Fallback** are hidden; rows and fallbacks already in use stay. See [Advanced settings](hub.md#advanced-settings).

### Countries

**Choose countries** lists **On your servers** (server counts; **verified** when an exit country is confirmed), then **All countries**. Search matches the code and the English or Russian name.

## Conditions

The builder edits pools, advanced step conditions, tags and **Recognized when** of network kinds.

| Control | Content |
| --- | --- |
| **Match** | **All conditions** (`and`) or **Any condition** (`or`). |
| **Condition {number}** | **Field**, **Operator** and **Value**, **Values, comma-separated** or **Pattern** with **Ignore case**. |
| **As text** | The condition text, checked as typed; a parse error blocks saving. |

Fields map to [Fields](../conditions.md#fields). A condition with nested groups shows "This condition nests groups, so it is edited as text." An empty condition reads **Any server**, or **Always** for a network.
