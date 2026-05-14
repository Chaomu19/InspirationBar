import Foundation

// 搜索结果和过滤逻辑
@MainActor
class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published var filteredProjects: [Project] = []
    @Published var filteredScratchNotes: [ScratchNote] = []

    private var allProjects: [Project] = []
    private var allScratchNotes: [ScratchNote] = []

    func updateData(projects: [Project], scratchNotes: [ScratchNote]) {
        allProjects = projects
        allScratchNotes = scratchNotes
        performSearch()
    }

    func performSearch() {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()

        guard !q.isEmpty else {
            filteredProjects = []
            filteredScratchNotes = []
            return
        }

        // 特殊前缀过滤
        if q.hasPrefix("tag:") {
            let tag = String(q.dropFirst(4))
            filteredProjects = allProjects.filter { project in
                project.tags.contains { $0.lowercased().contains(tag) }
            }
            filteredScratchNotes = allScratchNotes.filter { note in
                note.parsedTags.contains { $0.lowercased().contains(tag) }
            }
            return
        }

        // 全文搜索
        filteredProjects = allProjects.filter { project in
            project.title.lowercased().contains(q) ||
            project.detailMarkdown.lowercased().contains(q) ||
            project.tags.contains { $0.lowercased().contains(q) }
        }

        filteredScratchNotes = allScratchNotes.filter { note in
            note.content.lowercased().contains(q) ||
            note.parsedTags.contains { $0.lowercased().contains(q) }
        }
    }
}
