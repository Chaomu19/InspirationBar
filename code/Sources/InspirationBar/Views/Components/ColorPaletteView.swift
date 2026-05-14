import SwiftUI

// 颜色选择器：带左右微调按钮的水平色条
struct ColorPaletteView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @Binding var selectedHex: String
    var includesNoColor = true
    @State private var scrollPosition = 0

    var body: some View {
        HStack(spacing: 4) {
            scrollButton(systemName: "chevron.left") {
                scrollPosition = max(0, scrollPosition - 4)
            }

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 8) {
                        if includesNoColor {
                            noColorSwatch
                                .id(0)
                        }

                        ForEach(Array(ColorOption.palette.enumerated()), id: \.element.id) { index, option in
                            swatch(color: option.color, isSelected: option.hex == selectedHex)
                                .id(index + 1)
                                .onTapGesture {
                                    selectedHex = option.hex
                                    scrollPosition = index + 1
                                }
                                .help(option.name)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .onChange(of: scrollPosition) { target in
                    withAnimation(.easeOut(duration: 0.18)) {
                        proxy.scrollTo(target, anchor: .center)
                    }
                }
            }

            scrollButton(systemName: "chevron.right") {
                scrollPosition = min(ColorOption.palette.count, scrollPosition + 4)
            }
        }
        .frame(height: 30)
    }

    private func scrollButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 9, weight: .semibold))
                .frame(width: 16, height: 20)
                .foregroundColor(.secondary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var noColorSwatch: some View {
        swatch(color: Color.secondary.opacity(0.16), isSelected: selectedHex.isEmpty)
            .overlay {
                Image(systemName: "slash")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .onTapGesture {
                selectedHex = ""
                scrollPosition = 0
            }
            .help(viewModel.strings.text(.noColor))
    }

    private func swatch(color: Color, isSelected: Bool) -> some View {
        Circle()
            .fill(color)
            .frame(width: 16, height: 16)
            .overlay(
                Circle()
                    .stroke(
                        isSelected ? Color.primary : Color.clear,
                        lineWidth: 2.5
                    )
            )
            .overlay(
                Circle()
                    .stroke(
                        isSelected ? Color(.controlBackgroundColor) : Color.secondary.opacity(0.18),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 1, y: 1)
    }
}
