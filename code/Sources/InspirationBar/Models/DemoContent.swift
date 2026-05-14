import Foundation

enum DemoContent {
    static let version = 2

    static func projects(for language: AppLanguage) -> [Project] {
        switch language {
        case .chinese:
            return [
                Project(
                    title: "功能速览：编辑器快捷键",
                    detailMarkdown: """
                    # 编辑器快捷键速览

                    **项目**适合整理较完整的想法或方案，支持 Markdown 轻量排版。

                    ## 标题层级
                    选中文字后，Cmd + Plus（或 Cmd + =）提升标题层级，Cmd + Minus 降低层级。层级从 ### → ## → # → 引用块依次切换。

                    ### 加粗文字
                    选中文字按 Cmd + B 切换加粗，**试一试选中这段文字再按一次 Cmd + B**。

                    ## 撤回与重做
                    Cmd + Z 撤回，Cmd + Shift + Z 重做。每次输入都会自动记录快照，最多保存 30 步历史。

                    ### 颜色与标签
                    点击左上角圆点给项目选一个颜色，在下方标签栏输入标签名后按回车（或直接点击别处）添加标签。标签可用于后续搜索过滤。

                    > 提示：全部快捷键仅作用于编辑器正文区域。Cmd + Plus/Minus 调整的是光标所在行的标题级别。
                    """,
                    colorHex: "#FFD43B",
                    tags: ["入门", "快捷键"],
                    demoKey: "demo.project.release"
                ),
                Project(
                    title: "实用技巧：回收站与语言",
                    detailMarkdown: """
                    # 回收站、语言切换与搜索

                    ## 回收站机制
                    删除的项目和便签会进入**回收站**，保留 14 天后自动清理。在列表页点击垃圾桶图标可查看回收站，支持恢复或彻底删除。

                    ### 语言切换
                    点击菜单栏图标 → 设置（齿轮）→ 通用 → 语言，可在中文与 English 之间切换。演示内容也会同步切换语言。

                    ## 搜索功能
                    在搜索页支持全文检索项目和便签。使用 `tag:标签名` 语法可按标签过滤，例如搜索 `tag:反馈`。

                    ### 项目 vs 便签
                    - **项目**：适合结构化内容，有标题、标签、颜色和 Markdown 正文
                    - **便签**：适合即时碎片记录，在正文中用 #标签 即可自动识别

                    > 建议：需要反复回顾的内容放项目，一闪而过的想法放便签。
                    """,
                    colorHex: "#4DABF7",
                    tags: ["技巧", "回收站"],
                    demoKey: "demo.project.feedback"
                ),
            ]
        case .english:
            return [
                Project(
                    title: "Quick Tour: Editor Shortcuts",
                    detailMarkdown: """
                    # Editor Shortcuts Overview

                    **Projects** are great for structured ideas or plans, with lightweight Markdown formatting.

                    ## Heading Levels
                    Select a line and press Cmd + Plus (or Cmd + =) to increase the heading level, Cmd + Minus to decrease it. Levels cycle through ### → ## → # → blockquote.

                    ### Bold Text
                    Select text and press Cmd + B to toggle bold. **Try selecting this text and pressing Cmd + B again.**

                    ## Undo & Redo
                    Cmd + Z to undo, Cmd + Shift + Z to redo. A snapshot is recorded on every change, keeping up to 30 history steps.

                    ### Color & Tags
                    Click the colored dot in the top-left to pick a project color. Type a tag name in the tag bar and press Enter (or click away) to add it. Tags help with later search filtering.

                    > Tip: All shortcuts work inside the editor area. Cmd + Plus/Minus adjusts the heading level of the current line.
                    """,
                    colorHex: "#FFD43B",
                    tags: ["getting-started", "shortcuts"],
                    demoKey: "demo.project.release"
                ),
                Project(
                    title: "Tips: Trash & Language",
                    detailMarkdown: """
                    # Trash, Language & Search

                    ## Trash System
                    Deleted projects and notes go to the **Trash** and are kept for 14 days before permanent removal. Click the trash icon on the list page to browse, restore, or permanently delete items.

                    ### Language Switching
                    Click the menu bar icon → Settings (gear) → General → Language to switch between English and 中文. Demo content will update to match.

                    ## Search
                    The Search tab supports full-text search across projects and notes. Use `tag:name` syntax to filter by tag, e.g. `tag:feedback`.

                    ### Projects vs Notes
                    - **Projects**: best for structured content — title, tags, color, and Markdown body
                    - **Notes**: best for quick captures — use #tags inline for auto-detection

                    > Suggestion: put revisit-worthy content in Projects, fleeting thoughts in Notes.
                    """,
                    colorHex: "#4DABF7",
                    tags: ["tips", "trash"],
                    demoKey: "demo.project.feedback"
                ),
            ]
        }
    }

    static func scratchNotes(for language: AppLanguage) -> [ScratchNote] {
        switch language {
        case .chinese:
            return [
                ScratchNote(
                    content: "刚想到一个 #产品设计 点：用 Cmd + Z 撤回、Cmd + B 加粗编辑，快捷键让 Markdown 写作很顺手。#快捷键",
                    colorHex: "#FFD43B",
                    demoKey: "demo.note.product"
                ),
                ScratchNote(
                    content: "项目、便签删除后都在 #回收站 保留 14 天，不用怕误删。下次在设置里试试 #语言切换 到英文。",
                    colorHex: "#FFA94D",
                    demoKey: "demo.note.search"
                ),
            ]
        case .english:
            return [
                ScratchNote(
                    content: "Quick #product note: Cmd + Z to undo, Cmd + B for bold — Markdown shortcuts feel natural here. #shortcuts",
                    colorHex: "#FFD43B",
                    demoKey: "demo.note.product"
                ),
                ScratchNote(
                    content: "Deleted items stay in #trash for 14 days — no fear of accidental deletion. Try switching #language in Settings too.",
                    colorHex: "#FFA94D",
                    demoKey: "demo.note.search"
                ),
            ]
        }
    }
}
