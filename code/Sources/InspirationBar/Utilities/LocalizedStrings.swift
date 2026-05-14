import Foundation

struct LocalizedStrings {
    let language: AppLanguage

    func text(_ key: Key) -> String {
        switch language {
        case .chinese:
            return key.zh
        case .english:
            return key.en
        }
    }

    enum Key {
        case projects
        case scratch
        case search
        case list
        case add
        case newNote
        case backToEdit
        case delete
        case cancel
        case emptyProjectTitle
        case noProjects
        case createFirstProject
        case projectCount(Int)
        case noteCount(Int)
        case wordCount(Int)
        case noScratchNotes
        case emptyScratchNote
        case tagHint
        case scratchTitle
        case tagsLabel
        case createdAt(String)
        case chooseColor
        case deleteProjectHelp
        case deleteScratchHelp
        case deleteProjectConfirm(String)
        case deleteProjectSimpleConfirm
        case deleteScratchConfirm
        case deleteScratchDetailConfirm
        case noColor
        case searchPlaceholder
        case searchPrompt
        case searchTagHelp
        case noSearchResults
        case scratchTags
        case settingsGeneral
        case settingsAbout
        case settingsLanguage
        case settingsDefaultColors
        case settingsDefaultProjectColor
        case settingsDefaultScratchColor
        case settingsPopoverSize
        case settingsWidth
        case settingsHeight
        case settingsAutoSave
        case settingsSaveInterval
        case appDescription
        case xiaohongshu
        case creditMarkdownUI
        case quitApp
        case addTagPlaceholder
        case settingsMenu
        case aboutBar
        case trash
        case projectTrash
        case scratchTrash
        case restore
        case deleteForever
        case noTrashItems
        case trashRetention
        case deletedAt(String)
        case newProjectShort
        case newScratchShort
        case resetDefault
        case defaultBadge
        case launchAtLogin
        case faq
        case loginPromptTitle
        case loginPromptMessage
        case loginPromptEnable
        case loginPromptSkip

        var zh: String {
            switch self {
            case .projects: return "项目"
            case .scratch: return "便签"
            case .search: return "搜索"
            case .list: return "列表"
            case .add: return "新增"
            case .newNote: return "新建"
            case .backToEdit: return "返回编辑"
            case .delete: return "删除"
            case .cancel: return "取消"
            case .emptyProjectTitle: return "未命名项目"
            case .noProjects: return "还没有项目"
            case .createFirstProject: return "点击下方「新增」创建第一个项目"
            case .projectCount(let count): return "\(count) 个项目"
            case .noteCount(let count): return "\(count) 条便签"
            case .wordCount(let count): return "\(count) 字"
            case .noScratchNotes: return "还没有保存的便签"
            case .emptyScratchNote: return "空白便签"
            case .tagHint: return "可通过#添加标签"
            case .scratchTitle: return "便签"
            case .tagsLabel: return "标签:"
            case .createdAt(let date): return "创建于 \(date)"
            case .chooseColor: return "选择颜色"
            case .deleteProjectHelp: return "删除项目"
            case .deleteScratchHelp: return "删除便签"
            case .deleteProjectConfirm(let title): return "确定删除「\(title)」？此操作不可撤销。"
            case .deleteProjectSimpleConfirm: return "确定删除这个项目？"
            case .deleteScratchConfirm: return "确定删除这条便签？"
            case .deleteScratchDetailConfirm: return "确定删除这条便签？此操作不可撤销。"
            case .noColor: return "无色"
            case .searchPlaceholder: return "搜索项目、便签、标签... (tag:标签名)"
            case .searchPrompt: return "输入关键词搜索"
            case .searchTagHelp: return "支持 tag:标签名 按标签过滤"
            case .noSearchResults: return "没有找到匹配结果"
            case .scratchTags: return "便签标签"
            case .settingsGeneral: return "通用"
            case .settingsAbout: return "关于"
            case .settingsLanguage: return "语言"
            case .settingsDefaultColors: return "默认颜色"
            case .settingsDefaultProjectColor: return "新项目默认颜色"
            case .settingsDefaultScratchColor: return "新便签默认颜色"
            case .settingsPopoverSize: return "弹窗尺寸"
            case .settingsWidth: return "宽度"
            case .settingsHeight: return "高度"
            case .settingsAutoSave: return "自动保存"
            case .settingsSaveInterval: return "保存间隔"
            case .appDescription: return "一款简洁的 macOS 状态栏灵感记录工具"
            case .xiaohongshu: return "作者主页：小红书@Happymu"
            case .creditMarkdownUI: return "基于 swift-markdown-ui 构建"
            case .quitApp: return "退出 InspirationBar"
            case .addTagPlaceholder: return "添加标签..."
            case .settingsMenu: return "设置"
            case .aboutBar: return "关于 Bar"
            case .trash: return "回收站"
            case .projectTrash: return "项目回收站"
            case .scratchTrash: return "便签回收站"
            case .restore: return "恢复"
            case .deleteForever: return "彻底删除"
            case .noTrashItems: return "回收站为空"
            case .trashRetention: return "已删除内容会保留 14 天"
            case .deletedAt(let date): return "删除于 \(date)"
            case .newProjectShort: return "新项目"
            case .newScratchShort: return "新便签"
            case .resetDefault: return "回默认"
            case .defaultBadge: return "默认"
            case .launchAtLogin: return "开机启动"
            case .faq: return "常见问题"
            case .loginPromptTitle: return "开机自启动"
            case .loginPromptMessage: return "是否让 Inspiration Bar 在登录时自动启动？\n你可以随时在设置中更改此选项。"
            case .loginPromptEnable: return "开启"
            case .loginPromptSkip: return "跳过"
            }
        }

        var en: String {
            switch self {
            case .projects: return "Projects"
            case .scratch: return "Notes"
            case .search: return "Search"
            case .list: return "List"
            case .add: return "New"
            case .newNote: return "New"
            case .backToEdit: return "Back to edit"
            case .delete: return "Delete"
            case .cancel: return "Cancel"
            case .emptyProjectTitle: return "Untitled project"
            case .noProjects: return "No projects yet"
            case .createFirstProject: return "Click New below to create your first project"
            case .projectCount(let count): return "\(count) projects"
            case .noteCount(let count): return "\(count) notes"
            case .wordCount(let count): return "\(count) chars"
            case .noScratchNotes: return "No saved notes yet"
            case .emptyScratchNote: return "Empty note"
            case .tagHint: return "Use # to add tags"
            case .scratchTitle: return "Note"
            case .tagsLabel: return "Tags:"
            case .createdAt(let date): return "Created \(date)"
            case .chooseColor: return "Choose color"
            case .deleteProjectHelp: return "Delete project"
            case .deleteScratchHelp: return "Delete note"
            case .deleteProjectConfirm(let title): return "Delete \"\(title)\"? This cannot be undone."
            case .deleteProjectSimpleConfirm: return "Delete this project?"
            case .deleteScratchConfirm: return "Delete this note?"
            case .deleteScratchDetailConfirm: return "Delete this note? This cannot be undone."
            case .noColor: return "No color"
            case .searchPlaceholder: return "Search projects, notes, tags... (tag:name)"
            case .searchPrompt: return "Type to search"
            case .searchTagHelp: return "Use tag:name to filter by tag"
            case .noSearchResults: return "No matching results"
            case .scratchTags: return "Note tags"
            case .settingsGeneral: return "General"
            case .settingsAbout: return "About"
            case .settingsLanguage: return "Language"
            case .settingsDefaultColors: return "Default colors"
            case .settingsDefaultProjectColor: return "New project color"
            case .settingsDefaultScratchColor: return "New note color"
            case .settingsPopoverSize: return "Popover size"
            case .settingsWidth: return "Width"
            case .settingsHeight: return "Height"
            case .settingsAutoSave: return "Auto save"
            case .settingsSaveInterval: return "Save interval"
            case .appDescription: return "A lightweight macOS menu bar notebook for ideas"
            case .xiaohongshu: return "RED"
            case .creditMarkdownUI: return "Built with swift-markdown-ui"
            case .quitApp: return "Quit InspirationBar"
            case .addTagPlaceholder: return "Add tag..."
            case .settingsMenu: return "Settings"
            case .aboutBar: return "About Bar"
            case .trash: return "Trash"
            case .projectTrash: return "Project Trash"
            case .scratchTrash: return "Note Trash"
            case .restore: return "Restore"
            case .deleteForever: return "Delete forever"
            case .noTrashItems: return "Trash is empty"
            case .trashRetention: return "Deleted items are kept for 14 days"
            case .deletedAt(let date): return "Deleted \(date)"
            case .newProjectShort: return "New project"
            case .newScratchShort: return "New note"
            case .resetDefault: return "Reset"
            case .defaultBadge: return "Default"
            case .launchAtLogin: return "Launch at login"
            case .faq: return "FAQ"
            case .loginPromptTitle: return "Launch at Login"
            case .loginPromptMessage: return "Start Inspiration Bar automatically when you log in?\nYou can change this anytime in Settings."
            case .loginPromptEnable: return "Enable"
            case .loginPromptSkip: return "Skip"
            }
        }
    }
}
