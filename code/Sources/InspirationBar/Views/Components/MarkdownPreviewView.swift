import SwiftUI
import MarkdownUI

// Markdown 预览：透明背景，双击返回编辑模式
struct MarkdownPreviewView: View {
    let content: String
    var onDoubleTap: (() -> Void)?

    var body: some View {
        ScrollView {
            Markdown(content)
                .markdownBlockStyle(\.codeBlock) { configuration in
                    configuration.label
                        .padding(10)
                        .background(Color.secondary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .markdownTextStyle(\.code) {
                    FontFamilyVariant(.monospaced)
                    BackgroundColor(Color.secondary.opacity(0.08))
                }
                .textSelection(.enabled)
                .multilineTextAlignment(.leading)
                .padding(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .scrollContentBackground(.hidden)
        .onTapGesture(count: 2) {
            onDoubleTap?()
        }
    }
}
