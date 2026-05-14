import SwiftUI

// 搜索页：跨项目和便签的全文搜索 + 标签过滤
struct SearchView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var navigationPath: NavigationPath
    @StateObject private var searchVM = SearchViewModel()
    @FocusState private var isSearchFocused: Bool

    private var scratchTagCounts: [(tag: String, count: Int)] {
        let counts = viewModel.activeScratchNotes
            .flatMap(\.parsedTags)
            .reduce(into: [String: Int]()) { result, tag in
                result[tag, default: 0] += 1
            }

        return counts
            .map { (tag: $0.key, count: $0.value) }
            .sorted { lhs, rhs in
                if lhs.count == rhs.count {
                    return lhs.tag < rhs.tag
                }
                return lhs.count > rhs.count
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 搜索框
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 13))

                TextField(viewModel.strings.text(.searchPlaceholder), text: $searchVM.query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .focused($isSearchFocused)
                    .onChange(of: searchVM.query) { _ in
                        searchVM.performSearch()
                    }

                if !searchVM.query.isEmpty {
                    Button {
                        searchVM.query = ""
                        searchVM.performSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            if !scratchTagCounts.isEmpty {
                scratchTagList
            }

            Divider()

            // 搜索结果
            if searchVM.query.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "text.magnifyingglass")
                        .font(.system(size: 28))
                        .foregroundColor(.secondary.opacity(0.4))
                    Text(viewModel.strings.text(.searchPrompt))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Text(viewModel.strings.text(.searchTagHelp))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchVM.filteredProjects.isEmpty && searchVM.filteredScratchNotes.isEmpty {
                VStack(spacing: 8) {
                    Text(viewModel.strings.text(.noSearchResults))
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        // 项目结果
                        if !searchVM.filteredProjects.isEmpty {
                            sectionHeader(viewModel.strings.text(.projects), count: searchVM.filteredProjects.count)

                            ForEach(searchVM.filteredProjects) { project in
                                searchProjectRow(project)
                                    .onTapGesture {
                                        navigationPath.append(project)
                                    }
                            }
                        }

                        // 便签结果
                        if !searchVM.filteredScratchNotes.isEmpty {
                            sectionHeader(viewModel.strings.text(.scratch), count: searchVM.filteredScratchNotes.count)

                            ForEach(searchVM.filteredScratchNotes) { note in
                                searchScratchRow(note)
                                    .onTapGesture {
                                        navigationPath.append(note)
                                    }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
        .onAppear {
            searchVM.updateData(
                projects: viewModel.activeProjects,
                scratchNotes: viewModel.activeScratchNotes
            )
            isSearchFocused = true
        }
        .onChange(of: viewModel.activeProjects) { newVal in
            searchVM.updateData(
                projects: newVal,
                scratchNotes: viewModel.activeScratchNotes
            )
        }
        .onChange(of: viewModel.activeScratchNotes) { newVal in
            searchVM.updateData(
                projects: viewModel.activeProjects,
                scratchNotes: newVal
            )
        }
    }

    private var scratchTagList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                Text(viewModel.strings.text(.scratchTags))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)

                ForEach(scratchTagCounts, id: \.tag) { item in
                    Button {
                        searchVM.query = "tag:\(item.tag)"
                        searchVM.performSearch()
                    } label: {
                        HStack(spacing: 3) {
                            Text("#\(item.tag)")
                            Text("\(item.count)")
                                .foregroundColor(.secondary)
                        }
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.10))
                        .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary)
            Text("(\(count))")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    private func searchProjectRow(_ project: Project) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(Color(hex: project.colorHex))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
            Text(project.title.isEmpty ? viewModel.strings.text(.emptyProjectTitle) : project.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text(project.previewText)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    private func searchScratchRow(_ note: ScratchNote) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(note.colorHex.isEmpty ? Color.secondary.opacity(0.25) : Color(hex: note.colorHex))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(note.previewText.isEmpty ? viewModel.strings.text(.emptyScratchNote) : note.previewText)
                    .font(.system(size: 13))
                    .lineLimit(1)
                    .foregroundColor(note.content.isEmpty ? .secondary : .primary)

                let tags = note.parsedTags
                if !tags.isEmpty {
                    Text(tags.map { "#\($0)" }.joined(separator: " "))
                        .font(.system(size: 10))
                        .foregroundColor(note.colorHex.isEmpty ? .secondary : Color(hex: note.colorHex))
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
}
