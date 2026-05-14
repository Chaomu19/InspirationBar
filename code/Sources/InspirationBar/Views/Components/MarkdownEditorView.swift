import SwiftUI
import AppKit

// Markdown 编辑器：纯文本存储，编辑态实时渲染轻量 Markdown 样式。
struct MarkdownEditorView: View {
    @Binding var text: String
    private let undoManager: UndoRedoManager?
    private let placeholder: String?
    private let highlightTags: Bool

    init(
        text: Binding<String>,
        undoManager: UndoRedoManager? = nil,
        placeholder: String? = nil,
        highlightTags: Bool = false
    ) {
        _text = text
        self.undoManager = undoManager
        self.placeholder = placeholder
        self.highlightTags = highlightTags
    }

    var body: some View {
        PlainMarkdownTextEditor(
            text: $text,
            placeholder: placeholder,
            highlightTags: highlightTags,
            onTextChange: { newValue in
                undoManager?.snapshot(of: newValue)
            }
        )
    }
}

private struct PlainMarkdownTextEditor: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String?
    let highlightTags: Bool
    let onTextChange: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onTextChange: onTextChange)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true
        scrollView.backgroundColor = .textBackgroundColor
        scrollView.hasVerticalScroller = true

        let textView = ShortcutMarkdownTextView()
        textView.delegate = context.coordinator
        textView.string = text
        textView.placeholder = placeholder
        textView.highlightTags = highlightTags
        textView.font = .systemFont(ofSize: 13)
        textView.textColor = .labelColor
        textView.insertionPointColor = .labelColor
        textView.drawsBackground = true
        textView.backgroundColor = .textBackgroundColor
        textView.isRichText = false
        textView.importsGraphics = false
        textView.usesFontPanel = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.textContainerInset = NSSize(width: 8, height: 8)
        textView.textContainer?.lineFragmentPadding = 0
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true

        scrollView.documentView = textView
        context.coordinator.textView = textView
        textView.applyMarkdownStyles()
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? ShortcutMarkdownTextView else { return }

        scrollView.backgroundColor = .textBackgroundColor
        textView.backgroundColor = .textBackgroundColor
        textView.placeholder = placeholder
        textView.highlightTags = highlightTags
        if textView.string != text {
            let selectedRange = textView.selectedRange()
            textView.string = text
            textView.setSelectedRange(clampedRange(selectedRange, in: textView.string))
        }
        textView.applyMarkdownStyles()
        textView.needsDisplay = true
    }

    private func clampedRange(_ range: NSRange, in string: String) -> NSRange {
        let length = (string as NSString).length
        let location = min(range.location, length)
        return NSRange(location: location, length: min(range.length, length - location))
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        let onTextChange: (String) -> Void
        weak var textView: ShortcutMarkdownTextView?

        init(text: Binding<String>, onTextChange: @escaping (String) -> Void) {
            _text = text
            self.onTextChange = onTextChange
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text = textView.string
            onTextChange(textView.string)
            (textView as? ShortcutMarkdownTextView)?.applyMarkdownStyles()
            textView.needsDisplay = true
        }
    }
}

private final class ShortcutMarkdownTextView: NSTextView {
    private let bodyFont = NSFont.systemFont(ofSize: 13)
    private let noteFont = NSFont.systemFont(ofSize: 11)
    private let h3Font = NSFont.systemFont(ofSize: 16, weight: .semibold)
    private let h2Font = NSFont.systemFont(ofSize: 19, weight: .bold)
    private let h1Font = NSFont.systemFont(ofSize: 23, weight: .bold)
    private var isApplyingMarkdownStyles = false

    var placeholder: String?
    var highlightTags = false

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        guard string.isEmpty, let placeholder, !placeholder.isEmpty else { return }

        let origin = textContainerOrigin
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font ?? NSFont.systemFont(ofSize: 13),
            .foregroundColor: NSColor.secondaryLabelColor.withAlphaComponent(0.55),
        ]
        placeholder.draw(at: origin, withAttributes: attributes)
    }

    override func paste(_ sender: Any?) {
        guard let pastedText = NSPasteboard.general.string(forType: .string) else { return }
        insertText(pastedText, replacementRange: selectedRange())
    }

    override func copy(_ sender: Any?) {
        let selected = selectedRange()
        guard selected.length > 0 else { return }

        let rawText = (string as NSString).substring(with: selected)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(visiblePlainText(from: rawText), forType: .string)
    }

    override func keyDown(with event: NSEvent) {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        let isCommandShortcut = flags.contains(.command)
            && !flags.contains(.control)
            && !flags.contains(.option)
        let key = event.charactersIgnoringModifiers?.lowercased()

        if isCommandShortcut, key == "b" {
            toggleBold()
            applyMarkdownStyles()
            return
        }

        if isCommandShortcut, key == "+" || key == "=" {
            adjustHeading(increasing: true)
            applyMarkdownStyles()
            return
        }

        if isCommandShortcut, key == "-" {
            adjustHeading(increasing: false)
            applyMarkdownStyles()
            return
        }

        super.keyDown(with: event)
    }

    private func toggleBold() {
        let range = selectedRange()
        let nsString = string as NSString

        if range.length == 0 {
            replace(range: range, with: "****", selectedRange: NSRange(location: range.location + 2, length: 0))
            return
        }

        let beforeRange = NSRange(location: max(0, range.location - 2), length: 2)
        let afterRange = NSRange(location: range.location + range.length, length: 2)
        let hasWrappingMarkers = range.location >= 2
            && afterRange.location + afterRange.length <= nsString.length
            && nsString.substring(with: beforeRange) == "**"
            && nsString.substring(with: afterRange) == "**"

        if hasWrappingMarkers {
            let selectedText = nsString.substring(with: range)
            let fullRange = NSRange(location: range.location - 2, length: range.length + 4)
            replace(range: fullRange, with: selectedText, selectedRange: NSRange(location: range.location - 2, length: range.length))
        } else {
            let selectedText = nsString.substring(with: range)
            replace(
                range: range,
                with: "**\(selectedText)**",
                selectedRange: NSRange(location: range.location + 2, length: range.length)
            )
        }
    }

    private func adjustHeading(increasing: Bool) {
        let nsString = string as NSString
        let currentSelection = selectedRange()
        let lineRange = nsString.lineRange(for: currentSelection)
        let originalText = nsString.substring(with: lineRange)

        let transformed = originalText
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { line -> String in
                transformLine(String(line), increasing: increasing)
            }
            .joined(separator: "\n")

        let keepsTrailingNewline = originalText.hasSuffix("\n") && !transformed.hasSuffix("\n")
        let replacement = keepsTrailingNewline ? transformed + "\n" : transformed
        let delta = (replacement as NSString).length - lineRange.length
        let newLocation = max(lineRange.location, currentSelection.location + delta)

        replace(
            range: lineRange,
            with: replacement,
            selectedRange: NSRange(location: min(newLocation, lineRange.location + (replacement as NSString).length), length: 0)
        )
    }

    private func transformLine(_ line: String, increasing: Bool) -> String {
        let parsed = parseLineLevel(line)
        let nextLevel = increasing
            ? min(3, parsed.level + 1)
            : max(-1, parsed.level - 1)
        return prefix(for: nextLevel) + parsed.content
    }

    private func parseLineLevel(_ line: String) -> (level: Int, content: String) {
        if line.hasPrefix("### ") {
            return (1, String(line.dropFirst(4)))
        }
        if line.hasPrefix("## ") {
            return (2, String(line.dropFirst(3)))
        }
        if line.hasPrefix("# ") {
            return (3, String(line.dropFirst(2)))
        }
        if line.hasPrefix("> ") {
            return (-1, String(line.dropFirst(2)))
        }
        return (0, line)
    }

    private func prefix(for level: Int) -> String {
        switch level {
        case -1:
            return "> "
        case 1:
            return "### "
        case 2:
            return "## "
        case 3:
            return "# "
        default:
            return ""
        }
    }

    private func replace(range: NSRange, with replacement: String, selectedRange: NSRange) {
        guard shouldChangeText(in: range, replacementString: replacement) else { return }
        textStorage?.replaceCharacters(in: range, with: replacement)
        didChangeText()
        setSelectedRange(selectedRange)
    }

    func applyMarkdownStyles() {
        guard !isApplyingMarkdownStyles, let textStorage else { return }
        isApplyingMarkdownStyles = true
        defer { isApplyingMarkdownStyles = false }

        let selected = selectedRange()
        let fullRange = NSRange(location: 0, length: textStorage.length)

        textStorage.beginEditing()
        if fullRange.length > 0 {
            textStorage.setAttributes(baseAttributes, range: fullRange)
            applyLineStyles(to: textStorage)
            applyBoldStyles(to: textStorage)
            if highlightTags {
                applyTagStyles(to: textStorage)
            }
        }
        textStorage.endEditing()
        setSelectedRange(clampedRange(selected))
    }

    private var baseAttributes: [NSAttributedString.Key: Any] {
        [
            .font: bodyFont,
            .foregroundColor: NSColor.labelColor,
        ]
    }

    private var hiddenMarkerAttributes: [NSAttributedString.Key: Any] {
        [
            .font: NSFont.systemFont(ofSize: 1),
            .foregroundColor: NSColor.clear,
        ]
    }

    private func applyLineStyles(to textStorage: NSTextStorage) {
        let nsString = string as NSString
        var location = 0

        while location < nsString.length {
            let paragraphRange = nsString.paragraphRange(for: NSRange(location: location, length: 0))
            let paragraphText = nsString.substring(with: paragraphRange)
            let visibleLength = paragraphText.trimmingCharacters(in: .newlines).count

            if paragraphText.hasPrefix("# ") {
                applyBlockStyle(font: h1Font, markerLength: 2, paragraphRange: paragraphRange, visibleLength: visibleLength, textStorage: textStorage)
            } else if paragraphText.hasPrefix("## ") {
                applyBlockStyle(font: h2Font, markerLength: 3, paragraphRange: paragraphRange, visibleLength: visibleLength, textStorage: textStorage)
            } else if paragraphText.hasPrefix("### ") {
                applyBlockStyle(font: h3Font, markerLength: 4, paragraphRange: paragraphRange, visibleLength: visibleLength, textStorage: textStorage)
            } else if paragraphText.hasPrefix("> ") {
                applyBlockStyle(
                    font: noteFont,
                    markerLength: 2,
                    paragraphRange: paragraphRange,
                    visibleLength: visibleLength,
                    textStorage: textStorage,
                    foregroundColor: .secondaryLabelColor
                )
            }

            location = paragraphRange.upperBound
        }
    }

    private func applyBlockStyle(
        font: NSFont,
        markerLength: Int,
        paragraphRange: NSRange,
        visibleLength: Int,
        textStorage: NSTextStorage,
        foregroundColor: NSColor = .labelColor
    ) {
        let markerRange = NSRange(location: paragraphRange.location, length: min(markerLength, paragraphRange.length))
        textStorage.addAttributes(hiddenMarkerAttributes, range: markerRange)

        let contentLength = max(0, visibleLength - markerLength)
        guard contentLength > 0 else { return }

        let contentRange = NSRange(location: paragraphRange.location + markerLength, length: contentLength)
        textStorage.addAttributes(
            [
                .font: font,
                .foregroundColor: foregroundColor,
            ],
            range: contentRange
        )
    }

    private func applyBoldStyles(to textStorage: NSTextStorage) {
        let nsString = string as NSString
        var searchLocation = 0

        while searchLocation < nsString.length {
            let openRange = nsString.range(of: "**", options: [], range: NSRange(location: searchLocation, length: nsString.length - searchLocation))
            if openRange.location == NSNotFound { break }

            let closeSearchLocation = openRange.location + openRange.length
            if closeSearchLocation >= nsString.length { break }

            let closeRange = nsString.range(
                of: "**",
                options: [],
                range: NSRange(location: closeSearchLocation, length: nsString.length - closeSearchLocation)
            )
            if closeRange.location == NSNotFound { break }

            let contentRange = NSRange(
                location: openRange.location + openRange.length,
                length: closeRange.location - closeSearchLocation
            )

            textStorage.addAttributes(hiddenMarkerAttributes, range: openRange)
            textStorage.addAttributes(hiddenMarkerAttributes, range: closeRange)

            if contentRange.length > 0 {
                let currentFont = textStorage.attribute(.font, at: contentRange.location, effectiveRange: nil) as? NSFont ?? bodyFont
                textStorage.addAttribute(.font, value: boldFont(matching: currentFont), range: contentRange)
            }

            searchLocation = closeRange.location + closeRange.length
        }
    }

    private func applyTagStyles(to textStorage: NSTextStorage) {
        let nsString = string as NSString
        let pattern = "#[\\p{L}\\p{N}_]{2,}"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }

        let matches = regex.matches(
            in: string,
            range: NSRange(location: 0, length: nsString.length)
        )

        for match in matches {
            textStorage.addAttributes(
                [
                    .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
                    .foregroundColor: NSColor(calibratedRed: 0.76, green: 0.49, blue: 0.06, alpha: 1),
                ],
                range: match.range
            )
        }
    }

    private func boldFont(matching font: NSFont) -> NSFont {
        NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
    }

    private func visiblePlainText(from rawText: String) -> String {
        rawText
            .components(separatedBy: .newlines)
            .map { line in
                let withoutBlockMarker = parseLineLevel(line).content
                return withoutBlockMarker.replacingOccurrences(of: "**", with: "")
            }
            .joined(separator: "\n")
    }

    private func clampedRange(_ range: NSRange) -> NSRange {
        let length = (string as NSString).length
        let location = min(range.location, length)
        return NSRange(location: location, length: min(range.length, length - location))
    }
}
