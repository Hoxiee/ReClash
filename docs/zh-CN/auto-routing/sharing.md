# 共享与分发

介绍配置或场景如何在你与朋友之间、服务商与所有订阅用户之间传递，以及传递前如何通过验证器检查。应用中的相关按钮请参阅[编辑器共享指南](editor/sharing.md)。

目录：[配置包](#配置包) · [导出](#导出) · [导入与解包](#导入与解包) · [服务商分发](#服务商分发) · [rcx 链接](#rcx-链接) · [JSON Schema](#json-schema-与编辑器) · [rcxlint 工具](#rcxlint-工具)

## 配置包

**配置包**是一个包含多个配置和场景的 YAML 文件。场景通常会引用配置；若在其他设备上没有这些配置，场景就无法使用，因此需要配置包。

```yaml
rcx: 1
kind: bundle
title: Streaming
scenarios:
  streaming:
    rcx: 1
    title: Streaming
    groups:
      $main: { profile: user/streaming-fast }
profiles:
  streaming-fast:
    rcx: 1
    title: Streaming fast
    extends: builtin/fastest
    prefer:
      - label: Germany
        when: country = DE
      - label: Anything
        when: not dead
```

| 键 | 含义 |
| --- | --- |
| `rcx` | 格式版本：`1`。 |
| `kind: bundle` | 将文档标记为配置包。若缺少此字段，文件会被视作单个配置或场景。 |
| `title` | 导入时显示的标题。 |
| `scenarios` | 名称 → 场景的映射。 |
| `profiles` | 名称 → 配置的映射。 |

配置包必须采用 UTF-8 编码，且不超过 256 KiB。至少包含一个配置或场景，每个条目都必须是映射。

应用导出的配置包会将配置命名为 `user/<name>`；`rcxlint` 和导入预览均按此形式原样检查。

## 导出

导出配置或场景时：

- 如果只依赖内置配置，则导出该文档本身；
- 否则生成配置包，包含其通过 `extends` 和程序引用的所有非内置配置，无论引用层级有多深。

导出时会重写引用。依赖关系中的每个非内置配置都会变成一个*用户配置*，名称根据其标题生成（转为小写，其他字符连续出现时替换为 `-`），导出文档中的引用也会改为 `user/<new-name>`。`builtin/...` 引用保持不变。名称冲突时追加数字后缀（`-2`、`-3`）。

这就是**配置包**的保证：导出的设置会携带其引用的所有非内置配置。

## 导入与解包

应用读取文档时，首先判断它是否为配置包（`kind: bundle`）。普通配置或场景作为单个项目导入，名称取自标题；没有标题时使用 `profile` 或 `scenario`。

对于配置包，每个项目都会**重新命名**，以避免与用户库中的项目冲突。初始名称来自包内的键（转为小写，其他字符连续出现时替换为 `-`），必要时添加数字后缀。项目之间的引用也会更新，使导入后的场景指向导入的配置副本。

导入不会替换已有配置：如果已存在 `streaming-fast`，新配置会命名为 `streaming-fast-2`，场景引用也会相应更新。工作台会按照项目导入后在库中实际使用的名称，对整个配置包及其配置进行检查。

v3 设计要求提供往返测试（导出后再解包），并确保得到原文档。

## 服务商分发

服务商可以在订阅中提供配置和场景。完整规范见 [PROVIDER_FEATURES.md](../PROVIDER_FEATURES.md)，此处为摘要。

### 配置

| 方式 | 格式 |
| --- | --- |
| 内联 | 在订阅 YAML 顶层使用 `rcx-profiles: {name: profile}`，并在每个 `select` 组中使用 `rcx: {profiles: [...], default: name, chips: [{label, include}]}`。标准 mihomo 会忽略这两个字段。 |
| 配置包 | 在响应头中使用 `reclash-routing: <https url>`，或在正文中添加注释行 `#reclash-routing: <url>`。配置包 `{rcx: 1, profiles, groups, scenarios, scenario}` 最大 256 KiB，并按名称绑定到组。 |

订阅中的内联声明优先于配置包。服务商配置采用 `provider/<name>` 地址；`extends` 可引用 `builtin/<name>` 或其他服务商配置。服务商只能缩小组的节点池，不能启用 `direct-split`。连接服务商站点以外的主机需要用户[授权](engine.md#服务商配置的授权)。

```yaml
# 订阅片段（省略代理配置）
rcx-profiles:
  fast-de:
    rcx: 1
    title: Fast Germany
    prefer:
      - { label: Germany, when: 'country = DE' }
      - { label: Anything, when: 'not dead' }
proxy-groups:
  - name: Proxy
    type: select
    include-all: true
    rcx: { profiles: [fast-de], default: fast-de }
```

### 场景

| 方式 | 格式 |
| --- | --- |
| 内联 | 顶层 `rcx-scenarios: {name: scenario}` 和 `rcx-scenario: <name>`（默认场景）。 |
| 配置包 | `scenarios: {name: scenario}` 和 `scenario: <name>`。 |

内联声明优先于配置包。用户选择场景或关闭自动控制。若服务商场景的诊断会访问第三方主机，则需要授权。

```yaml
# 订阅片段（省略代理配置）
rcx-scenarios:
  work:
    rcx: 1
    title: Work
    description: Everything via Germany, internal sites direct.
    groups:
      $main: { profile: builtin/fastest }
    routes:
      - name: Intranet
        match: [DOMAIN-SUFFIX,corp.example]
        to: DIRECT
rcx-scenario: work
```

以下是完整的分发配置包，可直接通过 `rcxlint` 检查：

```yaml
rcx: 1
profiles:
  fast-de:
    rcx: 1
    title: Fast Germany
    prefer:
      - label: Germany
        when: country = DE
      - label: Anything
        when: not dead
scenarios:
  work:
    rcx: 1
    title: Work
    description: Everything via Germany, internal sites direct.
    groups:
      $main: { profile: provider/fast-de }
    routes:
      - name: Intranet
        match: [DOMAIN-SUFFIX,corp.example]
        to: DIRECT
scenario: work
```

## rcx 链接

可在聊天中发送链接来共享配置或场景。格式定义于 `lib/common/rcx_link.dart` 和 `lib/common/url_scheme.dart`。

```text
reclash://routing?p=<payload>
reclash://routing?url=<https url>
```

- `p` 携带 YAML：UTF-8 文本先以 raw deflate（级别 9）压缩，再编码为不带填充的 base64url。解压后的文本最多 64 KiB，且在解压过程中强制限制，避免小体积载荷膨胀成大文件。
- `url` 是包含文档的 `https://` 地址。下载文件最多 64 KiB。
- 链接必须且只能含有一个参数：`p` 或 `url`。其他内容（路径、片段、额外参数）会被视为无效链接并拒绝。
- 也可以将链接粘贴到导入框；应用会先解码链接，再读取文档。

链接会打开导入审核，而不是配置库：保存之前，用户会先看到检查结果并确认授权提示。

## JSON Schema 与编辑器

仓库根目录的 `rcx-profile.schema.json` 描述配置（位于 Schema 根节点）和配置包（位于 `$defs.bundle`）。该文件遵循 JSON Schema 2020-12；测试会比较它与 `core/rcx/profile.go` 的键集合，确保两者同步。

在支持 YAML Schema 的编辑器中（例如安装 YAML 扩展的 VS Code），将 Schema 关联到文件即可启用补全和行内错误提示。VS Code 设置示例：

```json
{
  "yaml.schemas": {
    "./rcx-profile.schema.json": "*.rcx.yaml"
  }
}
```

注意：

- Schema 检查结构和值的形式，但无法解析条件；它只限制条件长度为 2048 个字符，与应用相同。
- Schema 描述配置和配置包；场景应使用 `rcxlint` 检查。

## rcxlint 工具

`rcxlint` 按照应用导入时的方式检查文件：使用相同解析器、限制和消息，并提供行号。

```text
cd core
go run ./rcx/cmd/rcxlint <file.yaml>...
```

或者从仓库根目录运行：

```text
dart run tool/rcx.dart lint <file.yaml>...
```

工具会自动识别三种文件：

| 文件 | 识别方式 |
| --- | --- |
| 配置包 | 顶层存在 `profiles` 或 `scenarios` 键 |
| 场景 | 顶层存在 `groups`、`routes` 或 `mode` 键 |
| 配置 | 其他情况 |

普通文件的 ID 为 `provider/<file name>`。带有 `kind: bundle` 的文件会按应用的导入方式检查，其中配置使用 `user/<name>`。服务商配置包若没有 `kind`，配置使用 `provider/<name>`；工具还会检查默认场景是否存在，以及每个组绑定是否指向已定义配置。

无错误时退出码为 0，存在任意错误时为 1，用法错误时为 2。每个问题单独输出一行：

```text
bad.yaml:3: error: prefer 1 (): unknown field "bogus"
profiles.yaml: warning: profile provider/p contacts example.com; allow them first
```

警告（例如未使用的检查，或需要授权的主机）不会导致运行失败。工具会按服务商配置形式检查，因此连接第三方主机的配置总会显示授权警告；这是预期行为，导入时由用户决定是否允许。
