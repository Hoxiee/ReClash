# Routes, server order and pickers

This page covers the editing screens reached from the Routes tab: the traffic picker, the route editor, the server order (ladder) editor, the country picker and the condition builder.

## Add a route for one service

1. Open **Auto routing**, tab **Routes**.
2. Tap **Add route**. The page is titled **New route**.
3. Pick the services the route takes (see [the traffic picker](#the-traffic-picker)). The footer says: "Pick the services this route takes; you can add your own entries too."
4. Tap **Next**. It stays disabled until something is chosen.
5. The [route editor](#the-route-editor) opens with the name pre-filled from the first service you chose. If that name is already taken the field stays blank and you must type one.
6. Choose **Send through**, optionally edit the server order, and save.

What happens: ReClash creates a select group with the route's name, puts the route in the list, and re-applies the profile once. The route appears in the hub **Routes** list and in **Proxies**.

## The traffic picker

> [!NOTE]
> **Screenshot `route-traffic-picker`** — the New route page with the service chips YouTube and Gemini selected and the Custom section below.

### Services

Tap a chip to toggle a service. A chip is selected when all of the service's rules are present. The services are:

| Service | Service | Service |
| --- | --- | --- |
| ▶️ YouTube | 🔍 Google | ✨ Gemini |
| 🤖 ChatGPT | 🧠 Claude | ✈️ Telegram |
| 🎮 Discord | 💬 WhatsApp | 📷 Instagram |
| 👥 Facebook | 𝕏 X | 🎵 TikTok |
| 🎬 Netflix | 🎧 Spotify | 📺 Twitch |
| 🕹️ Steam | 🐙 GitHub | 🍎 Apple |
| 🪟 Microsoft | | |

Telegram also adds its IP ranges, so calls and media that do not use domain names follow the route.

### Custom entries

Under **Custom** ("Domains, IP ranges, apps or rule sets this route also takes.") tap **Add entry**. The entry form has:

| Control | Notes |
| --- | --- |
| **Type** | Menu of entry types (below). |
| **Value** | The value, with a type-specific hint. |
| **Don’t resolve domains** | Shown only for IP types. Leave off unless you know you need it. |

| Type | Matches | Example |
| --- | --- | --- |
| **Domain and subdomains** | The domain and every subdomain ("A domain suffix also covers every subdomain.") | `example.com` |
| **Domain** | Exactly this host | `www.example.com` |
| **Domain keyword** | Any host containing the word | `example` |
| **Site category** | A site list by name | `category-ai-chat-!cn`, `telegram` |
| **IP category** | A country or service IP list | `telegram` |
| **IP range** | A CIDR block. IPv6 is detected by a colon. | `10.0.0.0/8` |
| **App** | A process name (desktop) | `Telegram.exe` |
| **Rule set** | A named rule set of your profile | `my-rules` |

Rows show the value and the type. Tap a row to edit it; long-press for **Delete**.

### Validation

| Message | Cause |
| --- | --- |
| **Required** | Empty value. |
| **Invalid value** | Contains a comma or leading space; a domain with illegal characters; a category with characters outside letters, digits, `!@._-`; a CIDR that is not an address plus a valid prefix; a non-numeric port or AS number. |

Limits: at most 128 entries in a route and 32 routes in a scenario.

> [!NOTE]
> **Screenshot `route-entry-form`** — the entry form with Type "Site category" and an invalid value showing "Invalid value".

## The route editor

> [!NOTE]
> **Screenshot `route-editor`** — editor for "▶️ YouTube": name, traffic summary "YouTube · 2 more", Send through = Auto, server order, behaviour.

Its title is the route name (or **New route**). Controls from top to bottom:

| Control | What it does |
| --- | --- |
| **Name** | The route's name and its group's name. Hint `▶️ YouTube`. |
| Traffic summary | "YouTube · 2 more": services first, then custom values. Tap to open the picker again. |
| **Send through** | Auto, One server, Direct. |
| **Server** | Appears for One server. |
| **Server order** | Appears for Auto. See [below](#the-server-order-editor). |
| **Behaviour** | Appears for Auto. |
| **Leave out** | Appears for Auto (programs also have **Use**). Servers excluded for this route. |

### Name rules

| Message | Rule |
| --- | --- |
| **Required** | A name is needed. |
| **The name is too long** | At most 64 bytes in UTF-8 (emojis take 4 each). |
| **This name is reserved** | Not allowed: `$main`, `*`, `GLOBAL`, `DIRECT`, `REJECT`. |
| **{label} already exists** | Another route or a group of the subscription already has this name. |

Save is disabled while the name is invalid, while no traffic is chosen, or while **One server** has no server.

### Send through

| Option | Meaning |
| --- | --- |
| **Auto** | "The route’s own group picks the best server in the order below." |
| **One server** | "This traffic always goes through the chosen server or group." Pick it in **Server**: a sheet lists **Groups** and **Servers**. Not offered for the every-group rule. |
| **Direct** | "This traffic bypasses the proxy." Only for real routes. |

Switching away from Auto drops the server order, behaviour and exclusion of that route.

> [!NOTE]
> **Screenshot `route-editor-fixed`** — route editor with One server selected and the Server row choosing "🇳🇴 Oslo 1".

For rules on a group (Other groups) a different fixed option exists: **Hand to one member** with the row **Member**. "The whole group goes through this member with no server search; pick a load balancer or a nested group to hand it everything." Its summary reads "Through {member}".

### Behaviour

Tap **Behaviour** to choose how the group picks within your server order.

> [!NOTE]
> **Screenshot `route-behaviour`** — the Behaviour page with sections Built-in, From provider, User and the description footer.

- For a route the default is the built-in Simple.
- For rules on a group the first option is **Group's own profile** ("The group keeps the behaviour set in its own settings.").
- The footer shows the description of the selected behaviour.

### Use and Leave out

Rows open the [condition builder](#the-condition-builder). **Use** (default "Any server") narrows the pool of servers the group can use; **Leave out** (default "None") removes servers. Examples: Leave out `Provider is …` or `Latency over …`.

> [!NOTE]
> **Screenshot `route-pool`** — Leave out row showing "name contains …" and the Use row on a group rule.

### Saving

The editor checks the whole scenario on save. Errors belonging to a field show next to it; others show in a banner. See [troubleshooting.md](troubleshooting.md).

## The server order editor

The server order (called "ladder" in the contract) says which servers to prefer. Several steps form a priority list: step 1 is tried first, then step 2, and so on. The first step that has a working server decides. A server that does not work ranks after every working one, whatever its step.

> [!NOTE]
> **Screenshot `route-editor-ladder`** — Server order section with two steps ("⚡ RU" and "Any working server"), connectors, the caption "if none of them works" and the Add a step button.

### The list

Header **Server order** with two buttons: a sort toggle (shown with two or more steps) and **Add a step**.

| Part | Meaning |
| --- | --- |
| Number badge | The step's position. Highlighted when it is the step the current server sits on (group sheet only). |
| Title | The label, or a summary of the condition. |
| Subtitle | The condition, plus "Last resort" if set. |
| "N servers" at the right | How many servers fit now; red at zero. Group sheet only. |
| Caption between steps | The first connector reads "if none of them works". |
| Empty list | One row **Any working server**: "Add steps to prefer some servers over others". |

Long-press a step for **Delete**. Use the sort toggle to reorder. If you open a route that has no steps of its own, the steps of its behaviour are shown muted with: "From the behaviour — edit a step to make the order your own". Editing copies them into the route first.

Where a "when no step fits" setting exists it is stated as: "If no step has a working server: {action}", with actions **Go direct** or **Keep the current server**.

### The step builder

Tap **Add a step**, or tap an existing step. The title is **Add a step** or **Step {number}**; a delete icon appears when editing.

> [!NOTE]
> **Screenshot `ladder-step-editor`** — step editor with Name contains "⚡ RU", Country row, Add condition and the footer "2 servers fit now".

Section **Servers in this step**:

| Row | Meaning |
| --- | --- |
| **Name contains** | Text in the server name. Case does not matter. Characters like `*` and `.` are literal. Shown as "{text} in name". |
| **Country** | Opens the [country picker](#the-country-picker). The subtitle is "Any" or the country names (flags only past two countries). Shown as the country names. |
| **All but these countries** | A switch, visible once countries are chosen. Shown as "not {what}". |
| **Provider** | Servers from one provider ("from {provider}"). Options come from your servers. |
| **Protocol** | Server type, such as vless. |
| **Tag** | A named server set; only offered if the scenario or profile defines tags ("tag {tag}"). |
| **Supports UDP** | Only servers that carry UDP ("UDP"). |
| **Latency under, ms** | Default 300 ("under {ms} ms"). Digits only. |
| **Other conditions** | A condition the quick builder cannot show; tap to edit as text. |
| **Add condition** | A menu with the extra rows above and **Advanced condition…**. |

Added extra rows have a remove button. All rows must hold at once (they are joined with "and").

The footer reads "{count} server fits now" or "{count} servers fit now", calculated on your current servers. It is hidden when the condition cannot be tested locally.

Second section: **Label** (hint is the condition summary) and **Last resort**. "Servers in a last-resort step are used only when no other step has a working server, even a step below it."

### Worked example: YouTube prefers ⚡ RU, then any

1. Step 1: **Name contains** `⚡ RU`. Footer: 2 servers fit now.
2. Step 2: nothing selected, reads **Any working server**.

Moscow ⚡ 1 and 2 are used while they work; when both fail, any other working server takes over. Reverse the order and step 1 would catch everything.

### Worked example: Claude prefers Sweden

One step with **Country** set to Sweden (🇸🇪 Stockholm 1 and 2). Add a second step **Any working server** if you want a fallback; without it, no Swedish server working means the group has no server to prefer.

### Use of a last-resort step

Add a step with **Last resort** on for servers you only want when nothing else works (for example Premium NL). It can sit anywhere in the list; it still comes into play last.

## The country picker

> [!NOTE]
> **Screenshot `country-picker`** — Choose countries sheet with On your servers section (Norway 3 servers verified, Sweden 2 servers, Russia 2 servers) and All countries.

A sheet with a search field. Title **Choose countries** (several) or **Choose a country** (one; a tap picks it and closes).

| Section | Contents |
| --- | --- |
| **On your servers** | Countries found among your servers, with "{count} servers" and a "verified" mark when the exit country is confirmed by a check. |
| **All countries** | Every country, alphabetically. |

Search matches the ISO code, the English name or the Russian name. Selected rows show a check; tap the check in the app bar to confirm in multi mode.

How a server's country is known: the verified exit country if it is known, otherwise it is read from the name in this order: a flag emoji, an uppercase two-letter ISO code as a whole word, then an English country name. A server with no country never matches a country condition and never triggers a check just to learn its country.

## The condition builder

Used by **Use**, **Leave out**, **Advanced condition…**, **Other conditions**, tags and the **Recognized when** of network kinds.

> [!NOTE]
> **Screenshot `condition-builder`** — the builder with Match = All conditions and two conditions: Country is one of Norway, Sweden; Latency is under 300.

### Form mode

| Control | Notes |
| --- | --- |
| **Match** | **All conditions** or **Any condition**; shown with two or more conditions. |
| **Condition {number}** | One section per clause with a delete button. |
| **Field** | See table below. |
| **Operator** | **is**, **is not**, **is one of**, **matches**, **succeeds**, **fails**, **is under**, **is at most**, **is over**, **is at least**, with **not** variants. Yes/no for true-false fields. |
| **Value** / **Values, comma-separated** / **Pattern** | Depends on field and operator. |
| **Ignore case** | For **matches** (regular expression). |
| **Add condition** | New clause. |

| Field | Meaning |
| --- | --- |
| Name | Server name |
| Country | Verified exit country, or the one read from the name |
| Provider, Protocol, Server address | Where the server comes from |
| Supports UDP | Server carries UDP |
| Working, Not working | Health of the server |
| Measured | Server has a latency reading |
| In use | The group currently uses it |
| Latency ms | Last latency |
| Exit country, Entry country | Countries by check |
| Network kind, Connection type, Sign-in page, Metered network | Network conditions |
| Tag | Member of a tag |
| Passes check, Fails check, Network diagnostic | Results of checks declared by a profile |

For a country field with **is one of**, the value row opens the country picker. With **is**, it picks one.

An empty builder reads **Any server** (or **Always** for network conditions).

### Text mode

Section **As text** shows the condition as text, edited live (checked about 0.4 seconds after you stop typing). A parse error shows in a banner and disables saving. Conditions that nest groups show "This condition nests groups, so it is edited as text." The language is in [conditions.md](../conditions.md).

> [!NOTE]
> **Screenshot `condition-text`** — the As text section with a parse error banner.
