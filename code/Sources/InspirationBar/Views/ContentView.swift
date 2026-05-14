import SwiftUI

enum AppTab: CaseIterable {
    case projects
    case scratch
    case search

    var icon: String {
        switch self {
        case .projects: return "list.bullet.rectangle"
        case .scratch:  return "note.text"
        case .search:   return "magnifyingglass"
        }
    }

    func title(_ strings: LocalizedStrings) -> String {
        switch self {
        case .projects:
            return strings.text(.projects)
        case .scratch:
            return strings.text(.scratch)
        case .search:
            return strings.text(.search)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab: AppTab = .projects
    @State private var navigationPath = NavigationPath()
    @State private var scratchShowList = false  // 便签：false=编辑模式, true=列表模式

    var body: some View {
        VStack(spacing: 0) {
            tabBar

            Divider()

            NavigationStack(path: $navigationPath) {
                Group {
                    switch selectedTab {
                    case .projects:
                        ProjectListView(navigationPath: $navigationPath)
                    case .scratch:
                        ScratchNoteListView(
                            navigationPath: $navigationPath,
                            showList: $scratchShowList
                        )
                    case .search:
                        SearchView(navigationPath: $navigationPath)
                    }
                }
                .navigationDestination(for: Project.self) { project in
                    ProjectDetailView(project: project)
                }
                .navigationDestination(for: ScratchNote.self) { note in
                    ScratchNoteDetailView(note: note)
                }
            }
        }
        .frame(minWidth: 280, idealWidth: 320, minHeight: 340, idealHeight: 420)
        .background(.regularMaterial)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    if tab == selectedTab {
                        if tab == .scratch {
                            // 重复点击便签：切换编辑/列表模式
                            scratchShowList.toggle()
                        } else {
                            // 重复点击项目/搜索：回到列表
                            viewModel.activeProjectId = nil
                            navigationPath = NavigationPath()
                        }
                    } else {
                        // 切走前先确保持久化
                        viewModel.saveImmediately()
                        selectedTab = tab
                        // 根据各标签的活跃状态恢复或清空导航
                        switch tab {
                        case .projects:
                            if let id = viewModel.activeProjectId,
                               let project = viewModel.inspirationData.projects.first(where: { $0.id == id && $0.deletedAt == nil }) {
                                var path = NavigationPath()
                                path.append(project)
                                navigationPath = path
                            } else {
                                navigationPath = NavigationPath()
                            }
                        case .scratch:
                            if let id = viewModel.activeScratchNoteId,
                               let note = viewModel.inspirationData.scratchNotes.first(where: { $0.id == id && $0.deletedAt == nil }) {
                                var path = NavigationPath()
                                path.append(note)
                                navigationPath = path
                            } else {
                                navigationPath = NavigationPath()
                            }
                            scratchShowList = false
                        case .search:
                            navigationPath = NavigationPath()
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab == .scratch && scratchShowList && selectedTab == .scratch
                              ? "list.bullet.clipboard" : tab.icon)
                            .font(.system(size: 16))
                        Text(tab == .scratch && scratchShowList && selectedTab == .scratch
                             ? viewModel.strings.text(.list) : tab.title(viewModel.strings))
                            .font(.system(size: 11, weight: .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundColor(selectedTab == tab ? .accentColor : .secondary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 6)
    }
}
