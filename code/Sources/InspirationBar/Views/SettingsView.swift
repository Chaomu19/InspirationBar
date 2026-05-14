import SwiftUI

// 应用设置页
struct SettingsView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem {
                    Label(viewModel.strings.text(.settingsGeneral), systemImage: "gearshape")
                }
            AboutView()
                .tabItem {
                    Label(viewModel.strings.text(.settingsAbout), systemImage: "info.circle")
                }
        }
        .frame(width: 460, height: 320)
        .environmentObject(viewModel)
    }
}

private struct GeneralSettings: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        Form {
            Section {
                Toggle(viewModel.strings.text(.launchAtLogin), isOn: Binding(
                    get: { viewModel.settings.launchAtLogin },
                    set: { newValue in
                        viewModel.settings.launchAtLogin = newValue
                        viewModel.setLaunchAtLogin(newValue)
                    }
                ))
            }

            Section(viewModel.strings.text(.settingsLanguage)) {
                Picker(viewModel.strings.text(.settingsLanguage), selection: Binding(
                    get: { viewModel.settings.language },
                    set: { viewModel.setLanguage($0) }
                )) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(viewModel.strings.text(.settingsDefaultColors)) {
                VStack(alignment: .leading, spacing: 10) {
                    colorSetting(
                        title: viewModel.strings.text(.newProjectShort),
                        selection: Binding(
                            get: { viewModel.settings.defaultProjectColor },
                            set: { viewModel.settings.defaultProjectColor = $0 }
                        )
                    )
                    colorSetting(
                        title: viewModel.strings.text(.newScratchShort),
                        selection: Binding(
                            get: { viewModel.settings.defaultScratchColor },
                            set: { viewModel.settings.defaultScratchColor = $0 }
                        )
                    )
                }
            }

            Section(viewModel.strings.text(.settingsPopoverSize)) {
                sizeSetting(
                    title: viewModel.strings.text(.settingsWidth),
                    value: Binding(
                        get: { viewModel.settings.popoverWidth },
                        set: { viewModel.settings.popoverWidth = $0 }
                    ),
                    range: 300...600,
                    defaultValue: AppSettings.defaultPopoverWidth
                )
                sizeSetting(
                    title: viewModel.strings.text(.settingsHeight),
                    value: Binding(
                        get: { viewModel.settings.popoverHeight },
                        set: { viewModel.settings.popoverHeight = $0 }
                    ),
                    range: 350...800,
                    defaultValue: AppSettings.defaultPopoverHeight
                )
            }

            Section(viewModel.strings.text(.settingsAutoSave)) {
                HStack {
                    Text(viewModel.strings.text(.settingsSaveInterval))
                    Slider(value: Binding(
                        get: { viewModel.settings.autoSaveIntervalSeconds },
                        set: { viewModel.settings.autoSaveIntervalSeconds = $0 }
                    ), in: 1...10, step: 0.5)
                    Text("\(viewModel.settings.autoSaveIntervalSeconds, specifier: "%.1f")s")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.secondary)
                        .frame(width: 35)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func colorSetting(title: String, selection: Binding<String>) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 48, alignment: .leading)

            ColorPaletteView(selectedHex: selection, includesNoColor: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func sizeSetting(
        title: String,
        value: Binding<CGFloat>,
        range: ClosedRange<CGFloat>,
        defaultValue: CGFloat
    ) -> some View {
        let isDefault = abs(value.wrappedValue - defaultValue) < 0.5

        return HStack(spacing: 8) {
            Text(title)
                .frame(width: 44, alignment: .leading)

            Slider(
                value: Binding(
                    get: { Double(value.wrappedValue) },
                    set: { value.wrappedValue = CGFloat($0) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 10
            )

            Text("\(Int(value.wrappedValue))")
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 34)

            Text("\(viewModel.strings.text(.defaultBadge)) \(Int(defaultValue))")
                .font(.system(size: 10, weight: isDefault ? .semibold : .regular))
                .foregroundColor(isDefault ? .accentColor : .secondary)
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background((isDefault ? Color.accentColor : Color.secondary).opacity(0.10))
                .cornerRadius(4)

            Button(viewModel.strings.text(.resetDefault)) {
                value.wrappedValue = defaultValue
            }
            .font(.system(size: 10))
            .disabled(isDefault)
        }
    }
}

struct AboutView: View {
    @EnvironmentObject var viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("Inspiration Bar")
                .font(.system(size: 16, weight: .bold))

            Text("v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"))")
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Text(viewModel.strings.text(.appDescription))
                .font(.system(size: 12))
                .foregroundColor(.secondary)

            Text("MIT License")
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))

            Link(viewModel.strings.text(.xiaohongshu),
                 destination: URL(string: "https://www.xiaohongshu.com/user/profile/629cb86d00000000210228de")!)
                .font(.system(size: 12))

            Text(viewModel.strings.text(.creditMarkdownUI))
                .font(.system(size: 11))
                .foregroundColor(.secondary.opacity(0.7))
        }
        .frame(width: 300, height: 220)
        .padding(20)
    }
}
