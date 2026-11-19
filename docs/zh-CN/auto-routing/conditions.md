# 条件

RCX 条件语言参考:语法、字段、函数、三值逻辑与限制。

## 条件出现的位置

| 上下文 | 种类 | 可使用 |
| --- | --- | --- |
| `pool.include`、`pool.exclude`、`prefer[].when`、chips、场景程序 | 服务器 | 服务器和网络字段、`tag()`、`passes()`、`fails()` |
| `tags` 的值 | 服务器 | 服务器和网络字段、`passes()`、`fails()`;不能用 `tag()` |
| `network.kinds[].when`、`direct-split` | 网络 | 网络字段,以及仅限 `<diagnostic> ok` 或 `fail`;使用服务器字段会失败并报 `is about a server, not the network` |

空条件始终为真。

## 语法

```text
condition  = or
or         = and { "or" and }
and        = unary { "and" unary }
unary      = "not" unary | "(" or ")" | predicate
predicate  = boolfield
           | strfield ( "=" | "!=" ) value
           | strfield "in" "[" value { "," value } "]"
           | strfield "~" ( regex | string )
           | "latency" ( "=" | "!=" | "<" | "<=" | ">" | ">=" ) number
           | ( "tag" | "passes" | "fails" ) "(" name ")"
           | diagnostic ( "ok" | "fail" )
value      = word | string
word       = { letter | digit | "_" | "-" | "." | ":" }
string     = "'" { any but "'" } "'" | '"' { any but '"' } '"'
regex      = "/" { any, "\/" for a slash } "/" [ "i" ]
number     = digits [ "ms" ]
```

- 关键字(`and`、`or`、`not`、`in`、`ok`、`fail`)和字段名不区分大小写。`not` 结合最紧,其次是 `and`,然后是 `or`。
- 单独的 `!` 是错误:`use 'not' instead of '!'`。
- 字符串没有转义;含有空格、emoji 或其他 `word` 之外字符的值必须加引号。
- 正则为 RE2,不锚定;`i` 是唯一的标志。`~` 之后带引号的字符串同样被当作模式读取。
- 使用 `=`、`!=` 和 `in` 的字符串比较忽略大小写。

## 字段

### 服务器字段

| 字段 | 类型 | 值 | 何时未知 |
| --- | --- | --- | --- |
| `name` | string | 成员名称 | 从不 |
| `provider` | string | 提供该成员的代理提供者 | 从不 |
| `type` | string | mihomo 适配器类型,如 `Vless` 或 `Shadowsocks` | 从不 |
| `server` | string | 服务器主机或地址 | 从不 |
| `country` | country | 已验证的出口国家,否则取名称中的国家(旗帜或英文名称) | 从不;空值视为已知 |
| `exit.country` | country | 已验证的出口国家 | 尚未验证 |
| `entry.country` | country | 当 `server` 是 IP 地址时,其 GeoIP 国家 | `server` 是名称或不在数据库中 |
| `udp` | boolean | 成员支持 UDP | 从不 |
| `alive` | boolean | 健康状态为 `alive` | 从不 |
| `dead` | boolean | 健康状态为 `dead` | 从不 |
| `measured` | boolean | 有最近 6 小时内的延迟样本 | 从不 |
| `current` | boolean | 是当前选中的成员 | 从不 |
| `latency` | number,ms | 延迟中位数 | 从不;未 `measured` 时比较结果为假 |

国家值为 ISO 3166-1 alpha-2 代码(`NL`、`DE`)。

### 网络字段

| 字段 | 类型 | 值 |
| --- | --- | --- |
| `network.kind` | string | 已确认的网络类型 |
| `network.transport` | string | 在 Android 上为 `wifi`、`ethernet`、`cellular` 或 `other` |
| `network.portal` | boolean | 系统报告存在强制门户 |
| `metered` | boolean | 网络为计费网络 |

在平台报告网络之前,网络字段均为未知;在类型被确认之前,`network.kind` 为未知。

## 函数

| 形式 | 何时为真 | 错误 |
| --- | --- | --- |
| `tag(name)` | 该标签的条件对该成员确定为真;未知视为假。 | `unknown tag`;`tag(…) is not allowed here` |
| `passes(id)` | 检查 `id` 的最近一次结果为通过。 | `unknown check` |
| `fails(id)` | 检查 `id` 的最近一次结果为硬失败。 | `unknown check` |
| `<diagnostic> ok` | 诊断的任一目标应答。 | `<name> needs ok or fail` |
| `<diagnostic> fail` | 每个目标都已尝试且均未应答。 | |

从未运行过的检查为未知。失败的 `optional` 检查会使 `passes()` 和 `fails()` 都为假。通过的结果只有在连续两次失败后才会翻转;参见[证据](engine.md#evidence)。

## 三值逻辑

每个谓词为真、假或未知,按 Kleene 逻辑组合。

| A | B | A and B | A or B | not A |
| --- | --- | --- | --- | --- |
| true | unknown | unknown | true | false |
| false | unknown | false | unknown | true |
| unknown | unknown | unknown | unknown | unknown |

结果:

- 层级只有在条件为真时才计入成员。未知会使成员变为 `pending`,规划器可能对其进行检查。
- `pool.include` 放行未知;`pool.exclude` 只移除为真者。
- 未知的网络类型规则会阻止识别,直到其得到解析。

## 限制

| 项目 | 限制 |
| --- | --- |
| 条件长度 | 2048 个字符 |
| 嵌套 | 16 层;每个 `not` 和每对括号各增加一层 |
| 正则长度 | 512 个字符 |

## 示例

| 条件 | 含义 |
| --- | --- |
| `not dead` | 任何未被标记为死亡的成员 |
| `country in [NL, DE] and latency < 120ms` | 荷兰或德国,且已测量延迟低于 120 ms |
| `exit.country != RU and passes(open)` | 已验证出口不是 RU,且通过 open 检查 |
| `name ~ /premium/i` | 名称含有任意大小写的 `premium` |
| `name ~ '⚡ RU'` | 名称含有字面文本 `⚡ RU` |
| `udp and not type = Http` | 支持 UDP 且不是 HTTP 代理 |
| `metered or network.transport = cellular` | 网络条件:计费网络或移动数据 |
| `home ok and foreign fail` | 网络条件:仅 `home` 诊断有应答 |
