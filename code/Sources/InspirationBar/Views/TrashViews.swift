import SwiftUI

struct ProjectTrashView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header(title: viewModel.strings.text(.projectTrash))

            if viewModel.trashedProjects.isEmpty {
                emptyTrash
            } else {
                List {
                    ForEach(viewModel.trashedProjects) { project in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(project.colorHex.isEmpty ? Color.secondary.opacity(0.25) : Color(hex: project.colorHex))
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.title.isEmpty ? viewModel.strings.text(.emptyProjectTitle) : project.title)
                                    .font(.system(size: 12, weight: .medium))
                                    .lineLimit(1)

                                if let deletedAt = project.deletedAt {
                                    Text(viewModel.strings.text(.deletedAt(deletedAt.relativeDescription)))
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            Button(viewModel.strings.text(.restore)) {
                                viewModel.restoreProject(project)
                            }
                            .font(.system(size: 11))

                            Button(viewModel.strings.text(.deleteForever), role: .destructive) {
                                viewModel.permanentlyDeleteProject(project)
                            }
                            .font(.system(size: 11))
                        }
                        .padding(.vertical, 3)
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 360, height: 320)
    }

    private func header(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var emptyTrash: some View {
        VStack(spacing: 8) {
            Image(systemName: "trash")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.4))
            Text(viewModel.strings.text(.noTrashItems))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Text(viewModel.strings.text(.trashRetention))
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ScratchTrashView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header(title: viewModel.strings.text(.scratchTrash))

            if viewModel.trashedScratchNotes.isEmpty {
                emptyTrash
            } else {
                List {
                    ForEach(viewModel.trashedScratchNotes) { note in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(note.colorHex.isEmpty ? Color.secondary.opacity(0.25) : Color(hex: note.colorHex))
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(note.previewText.isEmpty ? viewModel.strings.text(.emptyScratchNote) : note.previewText)
                                    .font(.system(size: 12))
                                    .lineLimit(2)

                                if let deletedAt = note.deletedAt {
                                    Text(viewModel.strings.text(.deletedAt(deletedAt.relativeDescription)))
                                        .font(.system(size: 9))
                                        .foregroundColor(.secondary)
                                }
                            }

                            Spacer()

                            Button(viewModel.strings.text(.restore)) {
                                viewModel.restoreScratchNote(note)
                            }
                            .font(.system(size: 11))

                            Button(viewModel.strings.text(.deleteForever), role: .destructive) {
                                viewModel.permanentlyDeleteScratchNote(note)
                            }
                            .font(.system(size: 11))
                        }
                        .padding(.vertical, 3)
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 360, height: 320)
    }

    private func header(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var emptyTrash: some View {
        VStack(spacing: 8) {
            Image(systemName: "trash")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.4))
            Text(viewModel.strings.text(.noTrashItems))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Text(viewModel.strings.text(.trashRetention))
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
