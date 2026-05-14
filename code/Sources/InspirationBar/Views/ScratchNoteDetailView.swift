import SwiftUI

// 便签详情页：纯文本编辑 + 颜色选择 + 自动标签显示
struct ScratchNoteDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    let note: ScratchNote

    @State private var content: String
    @State private var colorHex: String
    @StateObject private var undoManager: UndoRedoManager
    @State private var showDeleteConfirm = false

    private var hasColor: Bool { !colorHex.isEmpty }
    private var currentColor: Color {
        hasColor ? Color(hex: colorHex) : Color.secondary.opacity(0.3)
    }

    init(note: ScratchNote) {
        self.note = note
        _content = State(initialValue: note.content)
        _colorHex = State(initialValue: note.colorHex)
        _undoManager = StateObject(wrappedValue: UndoRedoManager(initialText: note.content))
    }

    var body: some View {
        VStack(spacing: 0) {
            // 颜色强调条
            if hasColor {
                Rectangle()
                    .fill(Color(hex: colorHex))
                    .frame(height: 3)
            }

            // 颜色选择
            HStack {
                Text(viewModel.strings.text(.scratchTitle))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                ColorPaletteView(selectedHex: $colorHex)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)

            Divider()

            // 编辑器
            MarkdownEditorView(text: $content, undoManager: undoManager, placeholder: viewModel.strings.text(.tagHint), highlightTags: true)

            // 已解析的标签
            let parsed = TagParser.extract(from: content)
            if !parsed.isEmpty {
                Divider()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        Text(viewModel.strings.text(.tagsLabel))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        ForEach(parsed, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 10))
                                .foregroundColor(hasColor ? currentColor : .secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background((hasColor ? currentColor : Color.secondary).opacity(0.12))
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 10)
                }
                .padding(.vertical, 4)
            }

            Divider()

            // 底部操作栏
            HStack {
                Text(viewModel.strings.text(.createdAt(note.createdAt.relativeDescription)))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                Spacer()

                Button(role: .destructive) {
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                .foregroundColor(.red.opacity(0.7))
                .help(viewModel.strings.text(.deleteScratchHelp))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .onAppear {
            viewModel.activeScratchNoteId = note.id
        }
        .onDisappear {
            saveChanges()
        }
        .onChange(of: content) { _ in
            saveChanges()
        }
        .onChange(of: colorHex) { _ in
            saveChanges()
        }
        .confirmationDialog(viewModel.strings.text(.deleteScratchDetailConfirm), isPresented: $showDeleteConfirm) {
            Button(viewModel.strings.text(.delete), role: .destructive) {
                viewModel.deleteScratchNote(note)
                dismiss()
            }
            Button(viewModel.strings.text(.cancel), role: .cancel) {}
        }
    }

    private func saveChanges() {
        var updated = note
        updated.content = content
        updated.colorHex = colorHex
        viewModel.updateScratchNote(updated)
    }
}
