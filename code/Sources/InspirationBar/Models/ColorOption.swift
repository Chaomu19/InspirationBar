import SwiftUI

// 12 色调色板，在亮色和暗色菜单栏下均清晰可辨
struct ColorOption: Identifiable, Equatable, Codable {
    let id: String       // hex 值作为唯一标识
    let name: String
    let hex: String

    var color: Color { Color(hex: hex) }

    static let palette: [ColorOption] = [
        ColorOption(id: "#FF6B6B", name: "珊瑚",  hex: "#FF6B6B"),
        ColorOption(id: "#FFA94D", name: "橘橙",  hex: "#FFA94D"),
        ColorOption(id: "#FFD43B", name: "金盏",  hex: "#FFD43B"),
        ColorOption(id: "#69DB7C", name: "薄荷",  hex: "#69DB7C"),
        ColorOption(id: "#38D9A9", name: "青碧",  hex: "#38D9A9"),
        ColorOption(id: "#4DABF7", name: "天空",  hex: "#4DABF7"),
        ColorOption(id: "#748FFC", name: "长春花", hex: "#748FFC"),
        ColorOption(id: "#9775FA", name: "薰衣草", hex: "#9775FA"),
        ColorOption(id: "#F783AC", name: "玫瑰",  hex: "#F783AC"),
        ColorOption(id: "#86B049", name: "鼠尾草", hex: "#86B049"),
        ColorOption(id: "#ADB5BD", name: "岩板",  hex: "#ADB5BD"),
        ColorOption(id: "#A67C52", name: "摩卡",  hex: "#A67C52"),
    ]

    static let defaultProject = palette[5]   // 天空蓝
    static let defaultScratch  = palette[2]   // 金盏黄
}
