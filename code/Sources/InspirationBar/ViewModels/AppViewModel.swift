import SwiftUI
import Combine
import ServiceManagement

// 中央状态管理：数据加载、CRUD、防抖自动保存
@MainActor
class AppViewModel: ObservableObject {
    @Published var inspirationData: InspirationData
    private let store = DataStore()
    private var saveTask: Task<Void, Never>?
    var strings: LocalizedStrings {
        LocalizedStrings(language: settings.language)
    }

    // 非归档项目（按更新时间降序）
    var activeProjects: [Project] {
        inspirationData.projects
            .filter { !$0.isArchived && $0.deletedAt == nil }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var trashedProjects: [Project] {
        inspirationData.projects
            .filter { $0.deletedAt != nil }
            .sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
    }

    // 便签（按更新时间降序）
    var activeScratchNotes: [ScratchNote] {
        inspirationData.scratchNotes
            .filter { $0.deletedAt == nil }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var trashedScratchNotes: [ScratchNote] {
        inspirationData.scratchNotes
            .filter { $0.deletedAt != nil }
            .sorted { ($0.deletedAt ?? .distantPast) > ($1.deletedAt ?? .distantPast) }
    }

    // 跨标签保留正在编辑的项目/便签，切换回来时恢复详情页
    @Published var activeProjectId: UUID?
    @Published var activeScratchNoteId: UUID?

    // 便签编辑器草稿状态：标签切换时保持编辑上下文
    @Published var scratchDraftId: UUID?
    @Published var scratchDraftText: String = ""

    var settings: AppSettings {
        get { inspirationData.settings }
        set { inspirationData.settings = newValue; markDirty() }
    }

    var needsFirstLaunchPrompt: Bool { !inspirationData.settings.didCompleteSetup }

    init() {
        if let loaded = store.load() {
            inspirationData = loaded
            cleanupExpiredTrash()
            installMissingDemoContentIfNeeded()
        } else {
            inspirationData = InspirationData.default
            _ = store.save(inspirationData)
        }
    }

    func completeSetup() {
        inspirationData.settings.didCompleteSetup = true
        markDirty()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                CrashLogger.info("SMAppService 失败: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - 项目操作

    func addProject() {
        let project = Project(
            colorHex: settings.defaultProjectColor  // "" = 无色
        )
        inspirationData.projects.append(project)
        markDirty()
    }

    func deleteProject(_ project: Project) {
        rememberDeletedDemo(project.demoKey)
        if let index = inspirationData.projects.firstIndex(where: { $0.id == project.id }) {
            inspirationData.projects[index].deletedAt = Date()
            inspirationData.projects[index].isArchived = true
            inspirationData.projects[index].updatedAt = Date()
        }
        markDirty()
    }

    func restoreProject(_ project: Project) {
        if let index = inspirationData.projects.firstIndex(where: { $0.id == project.id }) {
            forgetDeletedDemo(project.demoKey)
            inspirationData.projects[index].deletedAt = nil
            inspirationData.projects[index].isArchived = false
            inspirationData.projects[index].updatedAt = Date()
            markDirty()
        }
    }

    func permanentlyDeleteProject(_ project: Project) {
        inspirationData.projects.removeAll { $0.id == project.id }
        markDirty()
    }

    func updateProject(_ project: Project) {
        if let index = inspirationData.projects.firstIndex(where: { $0.id == project.id }) {
            var updated = project
            updated.updatedAt = Date()
            inspirationData.projects[index] = updated
            markDirty()
        }
    }

    // MARK: - 便签操作

    func addScratchNote() {
        let note = ScratchNote(
            content: "",
            colorHex: settings.defaultScratchColor
        )
        inspirationData.scratchNotes.append(note)
        markDirty()
    }

    func deleteScratchNote(_ note: ScratchNote) {
        rememberDeletedDemo(note.demoKey)
        if let index = inspirationData.scratchNotes.firstIndex(where: { $0.id == note.id }) {
            inspirationData.scratchNotes[index].deletedAt = Date()
            inspirationData.scratchNotes[index].updatedAt = Date()
        }
        if scratchDraftId == note.id {
            scratchDraftId = nil
            scratchDraftText = ""
        }
        markDirty()
    }

    func restoreScratchNote(_ note: ScratchNote) {
        if let index = inspirationData.scratchNotes.firstIndex(where: { $0.id == note.id }) {
            forgetDeletedDemo(note.demoKey)
            inspirationData.scratchNotes[index].deletedAt = nil
            inspirationData.scratchNotes[index].updatedAt = Date()
            markDirty()
        }
    }

    func permanentlyDeleteScratchNote(_ note: ScratchNote) {
        inspirationData.scratchNotes.removeAll { $0.id == note.id }
        markDirty()
    }

    func updateScratchNote(_ note: ScratchNote) {
        if let index = inspirationData.scratchNotes.firstIndex(where: { $0.id == note.id }) {
            var updated = note
            updated.updatedAt = Date()
            inspirationData.scratchNotes[index] = updated
            markDirty()
        }
    }

    // MARK: - 保存

    func markDirty() {
        cleanupExpiredTrash()
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            guard let self = self else { return }
            let interval = inspirationData.settings.autoSaveIntervalSeconds
            try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            guard !Task.isCancelled else { return }
            _ = store.save(inspirationData)
        }
    }

    func saveImmediately() {
        saveTask?.cancel()
        cleanupExpiredTrash()
        _ = store.save(inspirationData)
    }

    private func cleanupExpiredTrash(now: Date = Date()) {
        let cutoff = now.addingTimeInterval(-14 * 24 * 60 * 60)
        inspirationData.projects.removeAll { project in
            guard let deletedAt = project.deletedAt else { return false }
            return deletedAt < cutoff
        }
        inspirationData.scratchNotes.removeAll { note in
            guard let deletedAt = note.deletedAt else { return false }
            return deletedAt < cutoff
        }
    }

    // MARK: - 语言与内置示例

    func setLanguage(_ language: AppLanguage) {
        guard settings.language != language else { return }
        inspirationData.settings.language = language
        refreshDemoContentForCurrentLanguage()
        markDirty()
    }

    private func rememberDeletedDemo(_ demoKey: String?) {
        guard let demoKey else { return }
        if !inspirationData.settings.deletedDemoKeys.contains(demoKey) {
            inspirationData.settings.deletedDemoKeys.append(demoKey)
        }
    }

    private func forgetDeletedDemo(_ demoKey: String?) {
        guard let demoKey else { return }
        inspirationData.settings.deletedDemoKeys.removeAll { $0 == demoKey }
    }

    private func installMissingDemoContentIfNeeded() {
        guard inspirationData.settings.installedDemoVersion < DemoContent.version else {
            return
        }

        removeLegacyUnkeyedDemoContent()

        let deleted = Set(inspirationData.settings.deletedDemoKeys)
        let existingProjectKeys = Set(inspirationData.projects.compactMap(\.demoKey))
        let existingNoteKeys = Set(inspirationData.scratchNotes.compactMap(\.demoKey))
        let language = inspirationData.settings.language

        let projectsToAdd = DemoContent.projects(for: language).filter { project in
            guard let key = project.demoKey else { return false }
            return !deleted.contains(key) && !existingProjectKeys.contains(key)
        }
        let notesToAdd = DemoContent.scratchNotes(for: language).filter { note in
            guard let key = note.demoKey else { return false }
            return !deleted.contains(key) && !existingNoteKeys.contains(key)
        }

        inspirationData.projects.append(contentsOf: projectsToAdd)
        inspirationData.scratchNotes.append(contentsOf: notesToAdd)

        // 刷新已存在的演示内容到最新版本
        refreshDemoContentForCurrentLanguage()

        inspirationData.settings.installedDemoVersion = DemoContent.version
        _ = store.save(inspirationData)
    }

    private func removeLegacyUnkeyedDemoContent() {
        inspirationData.projects.removeAll { project in
            project.demoKey == nil
                && project.title == "示例项目"
                && project.detailMarkdown.hasPrefix("# 欢迎使用 InspirationBar")
                && project.tags == ["入门"]
        }

        inspirationData.scratchNotes.removeAll { note in
            note.demoKey == nil
                && note.content == "一个关于 #产品设计 的突发灵感..."
        }
    }

    private func refreshDemoContentForCurrentLanguage() {
        let deleted = Set(inspirationData.settings.deletedDemoKeys)
        let projectTemplates = Dictionary(
            uniqueKeysWithValues: DemoContent.projects(for: inspirationData.settings.language).compactMap { project in
                project.demoKey.map { ($0, project) }
            }
        )
        let noteTemplates = Dictionary(
            uniqueKeysWithValues: DemoContent.scratchNotes(for: inspirationData.settings.language).compactMap { note in
                note.demoKey.map { ($0, note) }
            }
        )

        for index in inspirationData.projects.indices {
            guard
                let key = inspirationData.projects[index].demoKey,
                !deleted.contains(key),
                let template = projectTemplates[key]
            else {
                continue
            }

            let original = inspirationData.projects[index]
            inspirationData.projects[index] = Project(
                id: original.id,
                title: template.title,
                detailMarkdown: template.detailMarkdown,
                colorHex: template.colorHex,
                tags: template.tags,
                createdAt: original.createdAt,
                updatedAt: Date(),
                isArchived: original.isArchived,
                demoKey: key,
                deletedAt: original.deletedAt
            )
        }

        for index in inspirationData.scratchNotes.indices {
            guard
                let key = inspirationData.scratchNotes[index].demoKey,
                !deleted.contains(key),
                let template = noteTemplates[key]
            else {
                continue
            }

            let original = inspirationData.scratchNotes[index]
            inspirationData.scratchNotes[index] = ScratchNote(
                id: original.id,
                content: template.content,
                colorHex: template.colorHex,
                createdAt: original.createdAt,
                updatedAt: Date(),
                demoKey: key,
                deletedAt: original.deletedAt
            )
        }
    }
}
