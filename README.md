# Inspiration Bar

一款简洁的 **macOS 状态栏灵感记录工具** — 点击菜单栏灯泡图标即可快速记录想法。应用运行在状态栏，不占用 Dock 空间。
## 作者

- **小红书**：[作者主页：小红书@Happymu](https://www.xiaohongshu.com/user/profile/629cb86d00000000210228de)
- **GitHub**：[Chaomu19](https://github.com/Chaomu19)

## 功能

### 项目和便签
- **项目**：适合结构化内容，支持标题、颜色标记、标签归类和 Markdown 正文
- **便签**：适合即时碎片记录，正文中用 `#标签` 自动识别
- **搜索**：全文检索项目和便签，支持 `tag:标签名` 按标签过滤

### Markdown 编辑器快捷键
| 快捷键 | 功能 |
|--------|------|
| `Cmd + Z` | 撤回 |
| `Cmd + Shift + Z` | 重做（最多 30 步历史） |
| `Cmd + B` | 切换加粗 |
| `Cmd + =` 或 `Cmd + +` | 提升标题层级 |
| `Cmd + -` | 降低标题层级 |

标题层级循环切换：`### → ## → # → 引用块 > → 正文`

### 其他特性
- 12 色调色板 — 为项目和便签选色区分主题
- 标签管理 — 输入标签后按回车或点击别处自动保存
- 回收站 — 删除内容保留 14 天，支持恢复或彻底删除
- 中英文切换 — 设置中一键切换界面语言，演示内容同步翻译
- 自动保存 — 可配置 1–10 秒自动保存间隔

## 安装和运行

### 直接使用（无需开发环境）

**无需编译、无需 Xcode** — 下载仓库后，双击根目录下的 `InspirationBar.app` 即可直接运行。

> 首次打开时，macOS 可能提示"无法验证开发者"。请右键（或 Control + 点击）`InspirationBar.app` → 选择「打开」→ 再点「打开」即可。只需操作一次，以后正常双击打开。

### 从源码构建

如果你希望自行编译或修改代码：

```bash
cd code
chmod +x setup.sh && ./setup.sh    # 安装依赖并编译
./build_app.sh                      # 生成 .app
open ../InspirationBar.app          # 启动
```

> 需要 Xcode 14+ 和 macOS 13+

## 项目结构
```
InspirationBar/
├── InspirationBar.app   ← 可直接运行的应用程序
└── code/                ← Swift 源码
    ├── Sources/         ← 应用代码
    ├── Tests/           ← 单元测试
    ├── Package.swift    ← SwiftPM 配置
    ├── setup.sh         ← 环境安装脚本
    └── build_app.sh     ← 打包脚本
```

## 技术栈
- SwiftUI + AppKit（NSStatusBar 状态栏 / NSTextView 编辑器）
- [swift-markdown-ui](https://github.com/gonzalezreal/swift-markdown-ui) — Markdown 预览渲染
- SwiftPM 原生包管理



## 协议

MIT License
