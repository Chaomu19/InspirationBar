import SwiftUI

// 标签编辑：显示标签 chips + 输入框添加新标签
struct TagEditorView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var tags: [String]
    let accentColor: Color
    @State private var newTagText = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tags.indices, id: \.self) { i in
                    HStack(spacing: 3) {
                        Text("#\(tags[i])")
                            .font(.system(size: 10))
                            .foregroundColor(accentColor)
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 9))
                            .foregroundColor(accentColor.opacity(0.6))
                            .onTapGesture {
                                tags.remove(at: i)
                            }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(accentColor.opacity(0.12))
                    .cornerRadius(12)
                }

                // 添加新标签
                TextField(viewModel.strings.text(.addTagPlaceholder), text: $newTagText)
                    .font(.system(size: 11))
                    .frame(width: 80)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                    .focused($isInputFocused)
                    .onSubmit { commitTag() }
                    .onChange(of: isInputFocused) { focused in
                        if !focused { commitTag() }
                    }
            }
        }
    }

    private func commitTag() {
        let trimmed = newTagText
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "#", with: "")
            .lowercased()
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
        }
        newTagText = ""
    }
}
