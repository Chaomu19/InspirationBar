import SwiftUI

// 项目详情页：标题+颜色点 + 标签 + Markdown 编辑器
struct ProjectDetailView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss

    let project: Project

    @State private var title: String
    @State private var detailMarkdown: String
    @State private var colorHex: String
    @State private var tags: [String]
    @StateObject private var undoManager: UndoRedoManager
    @State private var showColorPicker = false

    init(project: Project) {
        self.project = project
        _title = State(initialValue: project.title)
        _detailMarkdown = State(initialValue: project.detailMarkdown)
        _colorHex = State(initialValue: project.colorHex)
        _tags = State(initialValue: project.tags)
        _undoManager = StateObject(wrappedValue: UndoRedoManager(initialText: project.detailMarkdown))
    }

    // 当前颜色（"" 表示无色）
    private var hasColor: Bool { !colorHex.isEmpty }
    private var currentColor: Color {
        hasColor ? Color(hex: colorHex) : Color.secondary.opacity(0.3)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 颜色强调条
            if hasColor {
                Rectangle()
                    .fill(Color(hex: colorHex))
                    .frame(height: 3)
            }

            // 标题行：颜色点 + 标题
            HStack(spacing: 8) {
                // 单色点选择器
                Button {
                    showColorPicker.toggle()
                } label: {
                    Circle()
                        .fill(currentColor)
                        .frame(width: 16, height: 16)
                        .overlay(
                            Circle()
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
                        )
                        .overlay(
                            Group {
                                if !hasColor {
                                    Image(systemName: "plus")
                                        .font(.system(size: 7, weight: .bold))
                                        .foregroundColor(.secondary)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showColorPicker, arrowEdge: .bottom) {
                    colorPickerPopover
                }
                .help(viewModel.strings.text(.chooseColor))

                TextField(viewModel.strings.text(.emptyProjectTitle), text: $title)
                    .font(.system(size: 15, weight: .semibold))
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)

            // 标签
            TagEditorView(tags: $tags, accentColor: hasColor ? currentColor : .accentColor)
                .padding(.horizontal, 10)
                .padding(.bottom, 6)

            Divider()

            // 编辑器
            MarkdownEditorView(text: $detailMarkdown, undoManager: undoManager)

            Divider()

            // 底部信息栏
            HStack {
                Text(viewModel.strings.text(.wordCount(detailMarkdown.count)))
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)

                Spacer()

                Button {
                    viewModel.activeProjectId = nil
                    saveChanges()
                    dismiss()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 11))
                        Text(viewModel.strings.text(.list))
                            .font(.system(size: 10))
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
        }
        .background(Color(nsColor: .textBackgroundColor))
        .onAppear {
            viewModel.activeProjectId = project.id
        }
        .onDisappear {
            saveChanges()
        }
        .onChange(of: title) { _ in
            saveChanges()
        }
        .onChange(of: detailMarkdown) { _ in
            saveChanges()
        }
        .onChange(of: tags) { _ in
            saveChanges()
        }
    }

    // 颜色选择弹窗
    private var colorPickerPopover: some View {
        VStack(spacing: 6) {
            // 无色选项
            Button {
                colorHex = ""
                showColorPicker = false
                DispatchQueue.main.async { saveChanges() }
            } label: {
                HStack {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1.5))
                    Text(viewModel.strings.text(.noColor))
                        .font(.system(size: 12))
                    Spacer()
                    if !hasColor {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()

            // 12 色调色板（分两行）
            let colors = ColorOption.palette
            let half = colors.count / 2
            VStack(spacing: 6) {
                colorRow(Array(colors[0..<half]))
                colorRow(Array(colors[half..<colors.count]))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
        .padding(.vertical, 8)
        .frame(width: 200)
    }

    private func colorRow(_ options: [ColorOption]) -> some View {
        HStack(spacing: 6) {
            ForEach(options) { option in
                Circle()
                    .fill(option.color)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Circle()
                            .stroke(option.hex == colorHex ? Color.primary : Color.clear, lineWidth: 2)
                    )
                    .overlay(
                        option.hex == colorHex
                            ? Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                            : nil
                    )
                    .onTapGesture {
                        colorHex = option.hex
                        showColorPicker = false
                        DispatchQueue.main.async { saveChanges() }
                    }
            }
        }
    }

    private func saveChanges() {
        var updated = project
        updated.title = title
        updated.detailMarkdown = detailMarkdown
        updated.colorHex = colorHex
        updated.tags = tags
        viewModel.updateProject(updated)
    }
}
