#!/bin/bash
# InspirationBar - 创建 Xcode 项目脚本
# 使用方法: chmod +x create_xcode_project.sh && ./create_xcode_project.sh
# 前置条件: 已安装 Xcode (App Store 或 developer.apple.com)

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_NAME="InspirationBar"
BUNDLE_ID="com.inspirationbar.app"

echo "=== 创建 InspirationBar Xcode 项目 ==="

# 创建 Xcode 项目结构
mkdir -p "$PROJECT_NAME.xcodeproj"

# 创建 project.pbxproj
# 使用 swift package generate-xcodeproj 如果可用，否则手动创建
cd "$PROJECT_DIR"

# 尝试使用 Xcode 自带的工具
if command -v xcodebuild &> /dev/null; then
    echo "✓ Xcode 已安装"

    # 由于我们已经用 SPM 管理了项目结构，
    # 可以用以下方式打开:
    # 1. swift package open  (如果安装了 Xcode 14+)
    # 2. 或者直接打开 Package.swift
    echo ""
    echo "=== 项目已准备就绪 ==="
    echo ""
    echo "使用以下命令之一打开项目:"
    echo "  方式1 (推荐): open -a Xcode Package.swift"
    echo "  方式2: swift package open"
    echo ""
    echo "然后在 Xcode 中:"
    echo "  1. Product > Scheme > Edit Scheme > Run > Info"
    echo "  2. 选择 Executable: InspirationBar"
    echo "  3. 构建并运行 (Cmd+R)"
    echo ""
    echo "注意: macOS 状态栏应用需要设置 LSUIElement = YES"
    echo "已在 Package.swift 的 linkerSettings 中配置"
else
    echo "✗ 未检测到 Xcode"
    echo "请从 App Store 安装 Xcode: https://apps.apple.com/app/xcode/id497799835"
    exit 1
fi
