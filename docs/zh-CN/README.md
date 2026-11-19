# ReClash 文档

面向与 ReClash 集成的订阅提供商，以及客户端自动路由语言 RCX 的技术参考。

## 机器可读来源

| 资源 | 用途 |
| --- | --- |
| [`provider-config.schema.json`](../../provider-config.schema.json) | 提供商清单的 JSON Schema |
| [`rcx-profile.schema.json`](../../rcx-profile.schema.json) | RCX 配置和场景的 JSON Schema |
| [`provider_standard.g.json`](../../provider_standard.g.json) | 自动生成的注册表，涵盖所有提供商响应头、别名和清单字段 |

## 约定

- 响应头名称不区分大小写。以 `code` 形式出现的响应头名称会链接到响应头参考中的对应条目。
- 每个页面都由 ReClash 仓库的 `docs/` 构建；每个页面上的源码链接标明了确切的提交。
