#!/bin/bash
# parse-video skill - 启动 HTTP 服务（自动下载版）
# 用法: bash scripts/serve.sh [端口]

set -e

# ============ 配置 ============
GITEE_OWNER="qiushuihanjing"
GITEE_REPO="parse-video-nomark"
GITEE_BRANCH="master"
BIN_DIR="${HOME}/.cache/parse-video"
PORT="${1:-8080}"
# ==============================

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
        return 0
    fi

    echo "📦 首次使用，正在下载 $binary_name..."

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
BINARY_NAME=$(detect_binary)
BINARY_PATH="${BIN_DIR}/${BINARY_NAME}"

download_binary "$BINARY_NAME" "$BINARY_PATH"

echo ""
echo "🚀 启动 parse-video 服务..."
echo "📍 端口: $PORT"
echo "🌐 访问 http://localhost:$PORT 查看 Web UI"
echo "按 Ctrl+C 停止服务"
echo "---"

"$BINARY_PATH" serve -p "$PORT"
