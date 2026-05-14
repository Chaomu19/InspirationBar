#!/bin/bash
# InspirationBar 项目设置脚本
# 使用方法: chmod +x setup.sh && ./setup.sh

set -e

echo "================================================"
echo "  InspirationBar - macOS 状态栏灵感记录"
echo "  项目设置脚本"
echo "================================================"
echo ""

# 检查 Xcode
if ! command -v xcodebuild &> /dev/null; then
    echo "未检测到 Xcode。需要安装 Xcode 才能编译此项目。"
    echo ""
    echo "安装方法（选一种）:"
    echo "  1. App Store: https://apps.apple.com/app/xcode/id497799835"
    echo "  2. 终端: mas install 497799835 (需要先安装 mas)"
    echo "  3. 官网下载: https://developer.apple.com/download/all/"
    echo ""
    echo "安装完成后，运行此命令确保 Xcode 路径正确:"
    echo "  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
    echo ""
    echo "然后重新运行此脚本:"
    echo "  ./setup.sh"
    exit 1
fi

echo "✓ Xcode 已安装: $(xcodebuild -version | head -1)"

# 切换到 Xcode 路径（如果还在用 CLT）
CURRENT_PATH=$(xcode-select -p)
if [[ "$CURRENT_PATH" == *"CommandLineTools"* ]]; then
    echo "切换 Xcode 路径..."
    sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
fi

echo ""
echo "正在解析 Swift 包依赖..."
cd "$(dirname "$0")"
swift package resolve 2>&1

echo ""
echo "✓ 依赖安装完成"
echo ""

# 尝试编译
echo "正在编译..."
if swift build 2>&1; then
    echo ""
    echo "✓ 编译成功！"
    echo ""
    echo "运行方式:"
    echo "  swift run"
    echo ""
    echo "生成可双击启动的 .app:"
    echo "  ./build_app.sh"
    echo ""
    echo "生成后可打开:"
    echo "  open ../InspirationBar.app"
    echo ""
    echo "也可以使用 Xcode 打开:"
    echo "  open -a Xcode Package.swift"
    echo ""
    echo "在 Xcode 中:"
    echo "  1. 选择 Product > Scheme > Edit Scheme"
    echo "  2. Run > Info > Executable: InspirationBar"
    echo "  3. Info.plist 中的 LSUIElement=YES 会自动隐藏 Dock 图标"
    echo "  4. 按 Cmd+R 构建并运行"
else
    echo ""
    echo "✗ 编译失败，请检查错误信息"
    exit 1
fi
