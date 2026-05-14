import SwiftUI

// 便签页：默认快速编辑，草稿状态在 ViewModel 中持久化，标签切换不丢失
struct ScratchNoteListView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var navigationPath: NavigationPath
    @Binding var showList: Bool

    @State private var noteToDelete: ScratchNote?
    @State private var showTrash = false

    private var editorText: Binding<String> {
        Binding(
            get: { viewModel.scratchDraftText },
            set: { viewModel.scratchDraftText = $0 }
        )
    }

    var body: some View {
        Group {
            if showList {
                listMode
            } else {
                editorMode
            }
        }
        .onAppear {
            // 如果没有草稿，准备空白编辑器
            if viewModel.scratchDraftText.isEmpty && viewModel.scratchDraftId == nil {
                // 全新启动，什么都不做（空白编辑器）
            }
        }
        .onChange(of: showList) { isList in
            if isList && !editorText.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty {
                commitCurrentNote()
            }
        }
        .onDisappear {
            // 切换标签页时保存草稿
            if !editorText.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty {
                commitCurrentNote()
            }
        }
        .confirmationDialog(viewModel.strings.text(.deleteScratchConfirm), isPresented: Binding(
            get: { noteToDelete != nil },
            set: { if !$0 { noteToDelete = nil } }
        )) {
            Button(viewModel.strings.text(.delete), role: .destructive) {
                if let n = noteToDelete {
                    viewModel.deleteScratchNote(n)
                    noteToDelete = nil
                }
            }
            Button(viewModel.strings.text(.cancel), role: .cancel) {
                noteToDelete = nil
            }
        }
    }

    // MARK: - 快速编辑模式

    private var editorMode: some View {
        VStack(spacing: 0) {
            MarkdownEditorView(text: editorText, placeholder: viewModel.strings.text(.tagHint), highlightTags: true)

            Divider()

            HStack {
                Text(viewModel.strings.text(.wordCount(editorText.wrappedValue.count)))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    showList = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 12))
                        Text(viewModel.strings.text(.list))
                            .font(.system(size: 11))
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)

                Button {
                    saveAndNew()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 13))
                        Text(viewModel.strings.text(.add))
                            .font(.system(size: 11))
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .background(Color(nsColor: .textBackgroundColor))
    }

    // MARK: - 列表模式

    private var listMode: some View {
        VStack(spacing: 0) {
            if viewModel.activeScratchNotes.isEmpty {
                emptyListView
            } else {
                List {
                    ForEach(viewModel.activeScratchNotes) { note in
                        scratchRow(note)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.scratchDraftText = note.content
                                viewModel.scratchDraftId = note.id
                                showList = false
                            }
                            .contextMenu {
	                                Button(viewModel.strings.text(.delete), role: .destructive) {
                                    noteToDelete = note
                                }
                            }
                    }
                    .onDelete { indexSet in
                        for i in indexSet {
                            viewModel.deleteScratchNote(viewModel.activeScratchNotes[i])
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(nsColor: .windowBackgroundColor))
            }

            Divider()

            HStack {
                Text(viewModel.strings.text(.noteCount(viewModel.activeScratchNotes.count)))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    showTrash = true
                } label: {
                    Image(systemName: viewModel.trashedScratchNotes.isEmpty ? "trash" : "trash.fill")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                .help(viewModel.strings.text(.scratchTrash))

                Button {
                    startNewNote()
                    showList = false
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 12))
                        Text(viewModel.strings.text(.newNote))
                            .font(.system(size: 11))
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $showTrash) {
            ScratchTrashView()
                .environmentObject(viewModel)
        }
    }

    private var emptyListView: some View {
        VStack(spacing: 10) {
            Image(systemName: "note.text")
                .font(.system(size: 28))
                .foregroundColor(.secondary.opacity(0.4))
            Text(viewModel.strings.text(.noScratchNotes))
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            Button(viewModel.strings.text(.backToEdit)) {
                showList = false
            }
            .font(.system(size: 12))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 列表行

    private func scratchRow(_ note: ScratchNote) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(note.colorHex.isEmpty ? Color.secondary.opacity(0.25) : Color(hex: note.colorHex))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                if note.content.isEmpty {
                    Text(viewModel.strings.text(.emptyScratchNote))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    Text(note.previewText)
                        .font(.system(size: 12))
                        .lineLimit(2)
                        .foregroundColor(.primary)
                }

                let tags = note.parsedTags
                if !tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(tags.prefix(3), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 9))
                                .foregroundColor(note.colorHex.isEmpty ? .secondary : Color(hex: note.colorHex))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background((note.colorHex.isEmpty ? Color.secondary : Color(hex: note.colorHex)).opacity(0.12))
                                .cornerRadius(3)
                        }
                    }
                }

                Text(note.updatedAt.relativeDescription)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding(.vertical, 3)
    }

    // MARK: - 操作

    private func commitCurrentNote() {
        let trimmed = editorText.wrappedValue.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        if let id = viewModel.scratchDraftId,
           let index = viewModel.inspirationData.scratchNotes.firstIndex(where: { $0.id == id }) {
            var note = viewModel.inspirationData.scratchNotes[index]
            note.content = editorText.wrappedValue
            note.updatedAt = Date()
            viewModel.inspirationData.scratchNotes[index] = note
        } else {
            let note = ScratchNote(
                content: editorText.wrappedValue,
                colorHex: viewModel.settings.defaultScratchColor
            )
            viewModel.inspirationData.scratchNotes.append(note)
            // 记住这个新笔记的 id，下次回来继续编辑
            viewModel.scratchDraftId = note.id
        }
        viewModel.markDirty()
    }

    private func saveAndNew() {
        commitCurrentNote()
        viewModel.scratchDraftText = ""
        viewModel.scratchDraftId = nil
    }

    private func startNewNote() {
        viewModel.scratchDraftText = ""
        viewModel.scratchDraftId = nil
    }
}
