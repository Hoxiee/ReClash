# Troubleshooting

Every message the editor shows, with its cause and what to do. Unknown codes from a newer Core appear as the raw code (for example `some.code`); update ReClash if you see one.

## Reasons on the status card

| Message | Meaning | What to do |
| --- | --- | --- |
| Controlled manually | The group is in Manual. | Choose **Auto** to let ReClash decide. |
| Holding the pinned server | Pinned and the server works. | Nothing. |
| Switched to the pinned server {node} | You pinned a server. | Nothing. |
| No working server in the pool; holding the current one | Every pool server fails. | Check the network; widen the pool (**Change to** > **Any**). |
| No working server; fell back to {node} | The behaviour chose a fallback. | Check your servers. |
| Selected the best available server | First selection. | Nothing. |
| Changed server; {from} is skipped for 15 minutes | You tapped **Change server**. | Wait, or pick again. |
| {from} stopped working; switched to the best standby | Failover. | Nothing; look at History. |
| {from} is no longer in the pool | The pool or subscription changed. | Check **Change to** and the name pattern. |
| No other working server to change to | **Change server** found nothing. | Update the subscription. |
| This is the best server | Nothing better. | Nothing. |
| Checking a better candidate | A check is running. | Wait. |
| Working; kept until it fails | A working server is kept. | Raise **Switching** to **Often** to move sooner. |
| Switched recently; holding before the next change | Dwell time. | Wait. |
| Switch limit reached ({limit} per hour) | Flap protection. | Wait, or use **Pinned**. |
| A faster server needs another measurement | Confirming. | Wait. |
| Moved to a server in “{tier}” | A step with higher priority has a server. | Nothing. |
| Switched from {from}: {gain} ms faster | Latency win. | Nothing. |
| Could not select the server | The Core refused the selection. | Check the group is a selector; restart the connection. |
| Will switch to {node} once a check confirms it | Pending upgrade. | Nothing. |
| May switch to {node} in {minutes} min | Pending upgrade after dwell. | Nothing. |
| Will switch to {node} if it stays {gain} ms faster | Pending upgrade. | Nothing. |
| The network looks down; no server is blamed | Several servers fail at once. | Check the network. |
| Network changed | Network switched; re-evaluating. | Nothing. |
| Paused while the network is “{kind}”: nothing is checked or switched | The network kind (for example a sign-in page) pauses auto routing. | Sign in or change network. |
| Direct sites now go through this group / Direct sites go direct again | Direct split toggled. | See [groups.md](groups.md#settings-page). |
| The scenario holds {node} | A route is set to One server. | Nothing. |
| The scenario moves to {node} | A fixed target is applied. | Nothing. |
| {node} is not in this group | A fixed server does not exist in the group. | Edit the route: **Send through** > **One server** > choose again. |
| Not in use: mode {mode} | The connection is not in rule mode. | Use rule mode. |

## Why a server is excluded

| Message | Meaning |
| --- | --- |
| Not in the pool | Not matched by the name pattern, **Use** or the chosen pool. |
| Excluded by the profile | Matched by **Leave out**. |
| Not a server | A group or built-in, not a server. |
| Skipped after “Change server” | Skipped for 15 minutes. |
| Matches no preference | Fits no step and no catch-all. Add **Any working server**. |
| Not checked yet | Waiting for a first measurement. |
| Not working | Health: failing. |

## Problems with groups and profiles

| Message | Cause | What to do |
| --- | --- | --- |
| Profile {profile} was not found; the default is used | The chosen behaviour was deleted. | Choose another in **Behaviour**. |
| Profile error: {error} | The profile fails to compile. | Open it in the [studio](studio.md) and fix the error. |
| This group is not a selector in the current config | The group type changed. | Check the subscription. |
| The group has no servers | Empty group. | Update the subscription. |
| Routing state could not be saved: {error} | Disk write failed. | Free disk space; retry. |
| Permission needed | Profile wants to contact sites. | [Allow](groups.md#consent) or choose another behaviour. |

## Route problems

| Message | Cause | What to do |
| --- | --- | --- |
| Route name taken (`route.name-taken`) | Another group in the subscription already has the route's name. | Rename the route. |
| Route target missing (`route.to-missing`) | The One server target was removed from the subscription. | Pick another target. |
| Route invalid (`route.invalid`) | The route fails validation. | Open the route and fix the field. |
| Routes apply in rule mode; the connection is in {mode} mode now. | Not in rule mode. | Switch to rule mode. |

Name field errors: **Required**, **The name is too long**, **This name is reserved**, **{label} already exists**. See [routes.md](routes.md#name-rules).

## Profile and scenario checks

Shown as **Warnings** or banners, prefixed "Line {line}:" when they point at text.

| Message | Meaning | What to do |
| --- | --- | --- |
| Check {check} is never used, so it never runs | A declared check is not referenced. | Use or delete it. |
| Contacts third-party sites: {hosts} | Consent needed. | Review the hosts; allow if trusted. |
| No server of {group} passes the filter | **Use** / **Leave out** removes all servers. | Loosen the filters. |
| Tag {tag} is never used | An unused tag. | Delete it. |
| No server of {group} is in “{tier}” right now | The step is empty now. | Fine if intended; otherwise change the condition. |
| “{tier}” repeats the condition of “{after}”, so nothing lands in it | A step is shadowed. | Reorder or delete it. |
| This config has no group {group} | The scenario names a group the subscription lacks. | Delete the rule or choose a real group. |
| Tag name: Latin letters, digits, - and _ only, up to 24 | Invalid tag name. | Rename. |
| Lowercase Latin letters, digits and dashes, up to 24 | Invalid network kind name. | Rename. |
| The pattern is not a valid regular expression | A bad name pattern. | Fix or clear it. |
| This condition nests groups, so it is edited as text. | Not an error. | Use **As text**. |
| Invalid value | Entry value rejected. | See [routes.md](routes.md#validation). |

## Other situations

| Situation | What to do |
| --- | --- |
| "Start the connection to see auto routing" | Start the connection. |
| "Start the app's core to check this profile." | Start the connection. |
| "Couldn't bring the changes over" | The original no longer merges; use **What changed** and apply by hand. |
| Save is greyed out | Look for a banner; the first error disables saving. |
| Link too large | Links hold up to 64 KiB of text; use **Export file**. |
| Import renamed my item | A title clashed; see [sharing.md](sharing.md#renaming-on-a-clash). |
