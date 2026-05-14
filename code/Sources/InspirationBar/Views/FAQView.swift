import SwiftUI

struct FAQView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                faqItem(
                    q: "Q: \(faqQ1)",
                    a: "A: \(faqA1)"
                )
                faqItem(
                    q: "Q: \(faqQ2)",
                    a: "A: \(faqA2)"
                )
                faqItem(
                    q: "Q: \(faqQ3)",
                    a: "A: \(faqA3)"
                )
                faqItem(
                    q: "Q: \(faqQ4)",
                    a: "A: \(faqA4)"
                )
                faqItem(
                    q: "Q: \(faqQ5)",
                    a: "A: \(faqA5)"
                )
            }
            .padding(20)
        }
        .frame(width: 420, height: 360)
    }

    private func faqItem(q: String, a: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(q)
                .font(.system(size: 12, weight: .semibold))
            Text(a)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - 本地化问答

    private var faqQ1: String {
        viewModel.settings.language == .chinese ? "如何开机自启动？" : "How to launch at login?"
    }
    private var faqA1: String {
        viewModel.settings.language == .chinese
            ? "首次启动时会弹出提示询问是否开启。也可以前往「设置 → 通用 → 开机启动」手动开关。"
            : "A prompt will ask on first launch. You can also toggle it in Settings → General → Launch at login."
    }

    private var faqQ2: String {
        viewModel.settings.language == .chinese ? "编辑器有哪些快捷键？" : "What editor shortcuts are available?"
    }
    private var faqA2: String {
        viewModel.settings.language == .chinese
            ? "Cmd+Z 撤回，Cmd+Shift+Z 重做，Cmd+B 加粗，Cmd+Plus 提升标题层级，Cmd+Minus 降低标题层级。"
            : "Cmd+Z undo, Cmd+Shift+Z redo, Cmd+B bold, Cmd+Plus increase heading, Cmd+Minus decrease heading."
    }

    private var faqQ3: String {
        viewModel.settings.language == .chinese ? "删除的内容能恢复吗？" : "Can deleted items be recovered?"
    }
    private var faqA3: String {
        viewModel.settings.language == .chinese
            ? "删除后进入回收站，保留 14 天。在列表页点击垃圾桶图标可查看、恢复或彻底删除。"
            : "Deleted items go to Trash and are kept for 14 days. Click the trash icon on the list page to restore or permanently delete."
    }

    private var faqQ4: String {
        viewModel.settings.language == .chinese ? "如何切换语言？" : "How to switch language?"
    }
    private var faqA4: String {
        viewModel.settings.language == .chinese
            ? "前往「设置 → 通用 → 语言」，在中文和 English 之间切换。演示内容会同步翻译。"
            : "Go to Settings → General → Language to switch between English and 中文. Demo content updates automatically."
    }

    private var faqQ5: String {
        viewModel.settings.language == .chinese ? "数据保存在哪里？" : "Where is data stored?"
    }
    private var faqA5: String {
        viewModel.settings.language == .chinese
            ? "所有数据保存在本地沙盒中，不会上传到任何服务器。你的灵感始终在你自己的电脑上。"
            : "All data is stored locally in the app sandbox. Nothing is uploaded to any server. Your ideas stay on your own computer."
    }
}
