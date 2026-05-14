import SwiftUI

struct ProjectListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var navigationPath: NavigationPath
    @State private var projectToDelete: Project?
    @State private var showTrash = false

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.activeProjects.isEmpty {
                emptyView
            } else {
                List {
                    ForEach(viewModel.activeProjects) { project in
                        projectRow(project)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                navigationPath.append(project)
                            }
                            .contextMenu {
                                Button(viewModel.strings.text(.delete), role: .destructive) {
                                    projectToDelete = project
                                }
                            }
                    }
                    .onDelete { indexSet in
                        for i in indexSet {
                            viewModel.deleteProject(viewModel.activeProjects[i])
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(nsColor: .windowBackgroundColor))
            }

            Divider()

            // 底部操作栏
            HStack {
                Text(viewModel.strings.text(.projectCount(viewModel.activeProjects.count)))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    showTrash = true
                } label: {
                    Image(systemName: viewModel.trashedProjects.isEmpty ? "trash" : "trash.fill")
                        .font(.system(size: 13))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .help(viewModel.strings.text(.projectTrash))

                Button {
                    viewModel.addProject()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 14))
                        Text(viewModel.strings.text(.add))
                            .font(.system(size: 12))
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            viewModel.activeProjectId = nil
        }
        .sheet(isPresented: $showTrash) {
            ProjectTrashView()
                .environmentObject(viewModel)
        }
        .confirmationDialog(viewModel.strings.text(.deleteProjectSimpleConfirm), isPresented: Binding(
            get: { projectToDelete != nil },
            set: { if !$0 { projectToDelete = nil } }
        )) {
            Button(viewModel.strings.text(.delete), role: .destructive) {
                if let p = projectToDelete {
                    viewModel.deleteProject(p)
                    projectToDelete = nil
                }
            }
            Button(viewModel.strings.text(.cancel), role: .cancel) {
                projectToDelete = nil
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "lightbulb")
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.5))
            Text(viewModel.strings.text(.noProjects))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Text(viewModel.strings.text(.createFirstProject))
                .font(.system(size: 12))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func projectRow(_ project: Project) -> some View {
        HStack(spacing: 10) {
            // 颜色标识点
            Circle()
                .fill(project.colorHex.isEmpty ? Color.secondary.opacity(0.25) : Color(hex: project.colorHex))
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 3) {
                Text(project.title.isEmpty ? viewModel.strings.text(.emptyProjectTitle) : project.title)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)

                HStack(spacing: 6) {
                    // 标签
                    ForEach(project.tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 10))
                            .foregroundColor(project.colorHex.isEmpty ? .secondary : Color(hex: project.colorHex))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                (project.colorHex.isEmpty ? Color.secondary : Color(hex: project.colorHex)).opacity(0.12)
                            )
                            .cornerRadius(4)
                    }

                    if project.tags.count > 3 {
                        Text("+\(project.tags.count - 3)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }

                    Spacer(minLength: 4)

                    Text(project.updatedAt.relativeDescription)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 4)
    }
}
