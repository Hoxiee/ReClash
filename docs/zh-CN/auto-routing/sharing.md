# 分享

包、导出与导入、`reclash://routing` 链接、服务商交付、同意、rcxlint 和 JSON schema。

## 包

包携带一个配置或场景，以及它所需的非内置配置。限制：256 KiB。

```yaml title="split-bundle.rcx.yaml"
rcx: 1
kind: bundle
title: Split with Norway
scenarios:
  split-with-norway:
    rcx: 1
    title: Split with Norway
    groups:
      $main: { profile: user/norway }
profiles:
  norway:
    rcx: 1
    title: Norway
    prefer:
      - { label: Norway, when: 'country = NO' }
      - { label: Any, when: 'not dead', last-resort: true }
```

| 键 | 说明 |
| --- | --- |
| `kind: bundle` | 标记为包；没有它，文件就是单个配置或场景。 |
| `title` | 主条目的标题。 |
| `scenarios` | 名称 → 场景的映射。 |
| `profiles` | 名称 → 配置的映射。 |

包至少需要一个配置或场景（`bundle holds no profiles or scenarios`）；每个条目都必须是映射。在包中，`user/<key>` 指向它自己的配置 `<key>`。

没有 `kind: bundle` 时，文件如果有顶层的 `groups`、`mode` 或 `routes` 键就是场景，否则是配置。

## 导出

导出从库中的某个条目开始。如果该条目只引用内置配置，则导出纯文档。否则它会变成一个包，其中包含该条目，以及通过 `extends`、程序中的 `profile`、`on.<kind>.groups` 或路由可达的每个配置，无论嵌套多深。

包内名称取自标题：转为小写，`a-z0-9` 之外的每一段连续字符变为 `-`，去除首尾，冲突时加上 `-2`、`-3`……。结果为空时使用 id 的最后一段。引用变为 `user/<name>`。

| 格式 | 内容 |
| --- | --- |
| **导出剪贴板** | YAML 文本。 |
| **复制链接** | 一个 `reclash://routing?p=…` 链接。 |
| **导出文件** | `<name>.rcx.yaml`。 |

## 导入

导入接受文件、剪贴板或链接。审阅界面会显示错误、警告、导入将联系的主机，以及在所选组中某个配置此刻会选择什么。检查需要 Core 正在运行。**添加到我的库**会把每个条目保存为用户配置或场景；不会开始运行任何内容。

纯文档以其标题命名。包内条目以其键命名，配置在前，并避开已占用的名称；`user/<key>` 引用会被改写为保存后的名称。导入绝不会替换已有条目。

## 链接

| 形式 | 内容 |
| --- | --- |
| `reclash://routing?p=<payload>` | 文档，经原始 DEFLATE 压缩并以无填充 base64url 编码。载荷最大 128 KiB；解码后的文本最大 64 KiB。 |
| `reclash://routing?url=https://…` | 应用从该 HTTPS URL 获取文档；最大 64 KiB。 |

链接恰好携带 `p` 或 `url` 之一，不含路径或片段。打开它会开始导入审阅。

## 服务商交付

订阅通过其服务商清单（`reclash-config` 请求头所指的 YAML 文件）的 `routing` 部分提供 RCX。该部分包含 `profiles`、`scenarios`、`scenario` 和 `bindings`（绑定按组名划分）。订阅正文不含任何 RCX 键。

服务商的配置和场景获得 id `provider/<name>`。字段语法和交付细节见[服务商清单](../providers/manifest.md#routing)。

## 同意

服务商的配置或场景可能通过检查、诊断和回显服务联系某些主机。以下主机无需询问即被允许：

- 默认的回显服务以及内置配置的每个端点；
- 服务商的可注册域名（取自订阅 URL）；
- 用户已经为此订阅允许的主机。

任何其他主机都会使该条目被搁置，直到用户允许；问题 `profile.consent` 会列出这些主机。使用此类配置的组运行 `builtin/simple`；此类场景不驱动任何组。对于配置，其 `extends` 链中的每个服务商条目都会被检查。用户自己的配置和场景从不需要同意。

## rcxlint

`rcxlint` 使用与应用相同的校验来检查配置、场景、包和服务商清单。

```sh
cd core
go run ./rcx/cmd/rcxlint profile.rcx.yaml scenario.rcx.yaml
dart run tool/rcx.dart lint profile.rcx.yaml
```

| 输入 | 识别依据 | 检查方式 |
| --- | --- | --- |
| 共享的包 | `kind: bundle` | 其配置按 `user/<key>` 检查 |
| 服务商清单 | `routing` 键 | 其配置和场景按 `provider/<name>` 检查；同时检查 `scenario`，以及每个绑定的 `default` 和 `profiles` 是否已定义 |
| 服务商路由文档 | 顶层的 `profiles` 或 `scenarios` | 与清单的 `routing` 部分相同 |
| 场景 | 顶层的 `groups`、`routes` 或 `mode` | `provider/<file name>` |
| 配置 | 其他所有情况 | `provider/<file name>` |

文件名会去掉 `.yaml` 和 `.rcx`。输出行：

```text
file:line: error: [profile X: | scenario X: ]message
file:line: warning: [profile X: | scenario X: ]message
file: note: [profile X: ]contacts third-party host H (use); the user must allow it
```

退出状态：没有错误为 0，有任何错误为 1，用法错误为 2。

### 警告

| 警告 | 含义 |
| --- | --- |
| `tag X is never used` | 没有任何条件引用该标签。 |
| `check X is never used, so it never runs` | 没有任何条件引用该检查。 |
| `tier A repeats the condition of B, so nothing lands in it` | 两个层级条件相同；后一个无法到达。 |
| `the pool admits no server of G` | 在应用中，针对运行中的组。 |
| `no server of G is in T right now` | 在应用中，针对运行中的组。 |
| `this config has no group G` | 在应用中，针对场景目标。 |

## JSON schema

仓库根目录下的 `rcx-profile.schema.json` 在根级别校验配置；`$defs.scenario` 涵盖场景。它检查结构和值的形态，不检查条件。清单的 `routing` 部分由 `rcxlint` 检查。

```json title=".vscode/settings.json"
{
  "yaml.schemas": {
    "./rcx-profile.schema.json": "*.rcx.yaml"
  }
}
```
