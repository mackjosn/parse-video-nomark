#!/bin/bash
# parse-video skill - 解析视频分享链接（自动下载版）
# 用法: bash scripts/parse.sh "<视频分享链接>"

set -e

# ============ 配置 ============
GITEE_OWNER="qiushuihanjing"
GITEE_REPO="parse-video-nomark"
GITEE_BRANCH="master"
BIN_DIR="${HOME}/.cache/parse-video"
# ==============================

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# 检测操作系统和架构
detect_binary() {
    local os_type arch_type

    case "$(uname -s)" in
        Darwin*)  os_type="darwin" ;;
        MINGW*|MSYS*|CYGWIN*|Windows*) os_type="win64" ;;
        *)        os_type="linux" ;;
    esac

    case "$(uname -m)" in
        arm64|aarch64) arch_type="arm64" ;;
        x86_64|amd64)   arch_type="amd64" ;;
        *)              arch_type="amd64" ;;
    esac

    # macOS 优先 arm64（兼容 Intel Mac）
    if [[ "$os_type" == "darwin" ]]; then
        arch_type="arm64"
    fi

    echo "parse-video-${os_type}-${arch_type}"
}

# 下载二进制
download_binary() {
    local binary_name="$1"
    local binary_path="$2"

    mkdir -p "$BIN_DIR"

    if [[ -f "$binary_path" && -x "$binary_path" ]]; then
        # 已有可执行文件，跳过下载
        return 0
    fi

    echo "📦 首次使用，正在下载 $binary_name..."

    # Gitee raw URL
    local download_url="https://gitee.com/${GITEE_OWNER}/${GITEE_REPO}/raw/${GITEE_BRANCH}/dist/${binary_name}"

    if command -v curl &>/dev/null; then
        curl -L --progress-bar -o "$binary_path" "$download_url"
    elif command -v wget &>/dev/null; then
        wget -O "$binary_path" "$download_url"
    else
        echo "错误: 需要 curl 或 wget"
        exit 1
    fi

    chmod +x "$binary_path"
    echo "✅ 下载完成: $binary_path"
}

# ============ 主逻辑 ============
if [ -z "$1" ]; then
    echo "用法: bash scripts/parse.sh \"<视频分享链接>\""
    echo ""
    echo "示例:"
    echo '  bash scripts/parse.sh "https://v.douyin.com/xxx"'
    echo '  bash scripts/parse.sh "https://www.doubao.com/video-sharing?share_id=xxx&video_id=xxx"'
    echo '  bash scripts/parse.sh "https://b23.tv/xxx"'
    exit 1
fi

VIDEO_URL="$1"
BINARY_NAME=$(detect_binary)
BINARY_PATH="${BIN_DIR}/${BINARY_NAME}"

# 下载二进制（如需要）
download_binary "$BINARY_NAME" "$BINARY_PATH"

# 执行解析
echo ""
echo "🔍 正在解析: $VIDEO_URL"
echo "---"
"$BINARY_PATH" parse "$VIDEO_URL"
