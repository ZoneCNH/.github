#!/bin/bash
# setup-global-rules.sh
# 一键配置全局规则到本地开发环境
#
# 使用方式：
#   curl -sSL https://raw.githubusercontent.com/ZoneCNH/.github/main/scripts/setup-global-rules.sh | bash
#   或
#   bash .github/scripts/setup-global-rules.sh

set -euo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ORG_CONFIG_DIR="${HOME}/org-config"
CLAUDE_RULES_DIR="${HOME}/.claude/rules"
REPO_URL="git@github.com:ZoneCNH/.github.git"

echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  全局规则初始化工具 v1.0             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
echo ""

# 1. 克隆/更新组织配置
if [ -d "${ORG_CONFIG_DIR}" ]; then
  echo -e "${YELLOW}🔄 更新组织配置...${NC}"
  cd "${ORG_CONFIG_DIR}" && git pull --quiet
  echo -e "${GREEN}✅ 已更新到最新版本${NC}"
else
  echo -e "${YELLOW}📥 克隆组织配置...${NC}"
  git clone --quiet "${REPO_URL}" "${ORG_CONFIG_DIR}"
  echo -e "${GREEN}✅ 克隆完成${NC}"
fi

# 2. 创建规则目录
mkdir -p "${CLAUDE_RULES_DIR}"

# 3. 创建 symlinks
echo ""
echo -e "${BLUE}🔗 创建规则链接...${NC}"

# Rust 规则
if [ -f "${ORG_CONFIG_DIR}/rulesets/rust/RULES.md" ]; then
  ln -sf "${ORG_CONFIG_DIR}/rulesets/rust/RULES.md" "${CLAUDE_RULES_DIR}/rust.md"
  echo -e "  ${GREEN}✅ Rust 规则${NC}"
fi

# Python 规则
if [ -f "${ORG_CONFIG_DIR}/rulesets/python/RULES.md" ]; then
  ln -sf "${ORG_CONFIG_DIR}/rulesets/python/RULES.md" "${CLAUDE_RULES_DIR}/python.md"
  echo -e "  ${GREEN}✅ Python 规则${NC}"
fi

# Agent 执行纪律
if [ -f "${ORG_CONFIG_DIR}/rulesets/agent-discipline.md" ]; then
  ln -sf "${ORG_CONFIG_DIR}/rulesets/agent-discipline.md" "${CLAUDE_RULES_DIR}/agent-discipline.md"
  echo -e "  ${GREEN}✅ Agent 执行纪律${NC}"
fi

# Agent 工作流编排
if [ -f "${ORG_CONFIG_DIR}/rulesets/agent-workflow.md" ]; then
  ln -sf "${ORG_CONFIG_DIR}/rulesets/agent-workflow.md" "${CLAUDE_RULES_DIR}/agent-workflow.md"
  echo -e "  ${GREEN}✅ Agent 工作流编排${NC}"
fi

# Agent 安全护栏
if [ -f "${ORG_CONFIG_DIR}/rulesets/agent-safety.md" ]; then
  ln -sf "${ORG_CONFIG_DIR}/rulesets/agent-safety.md" "${CLAUDE_RULES_DIR}/agent-safety.md"
  echo -e "  ${GREEN}✅ Agent 安全护栏${NC}"
fi

# Agent 上下文管理
if [ -f "${ORG_CONFIG_DIR}/rulesets/agent-context.md" ]; then
  ln -sf "${ORG_CONFIG_DIR}/rulesets/agent-context.md" "${CLAUDE_RULES_DIR}/agent-context.md"
  echo -e "  ${GREEN}✅ Agent 上下文管理${NC}"
fi

# 4. 验证
echo ""
echo -e "${BLUE}📋 验证结果：${NC}"
echo -e "  规则目录：${CLAUDE_RULES_DIR}"
ls -la "${CLAUDE_RULES_DIR}"/*.md 2>/dev/null | while read line; do
  echo -e "  ${GREEN}${line}${NC}"
done

# 5. 统计
RULE_COUNT=$(find "${ORG_CONFIG_DIR}/rulesets" -name "*.md" | wc -l)
echo ""
echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  全局规则配置完成！                  ║${NC}"
echo -e "${GREEN}║  共 ${RULE_COUNT} 篇规则，覆盖所有组织项目     ║${NC}"
echo -e "${GREEN}║                                      ║${NC}"
echo -e "${GREEN}║  更新规则：cd ~/org-config && git pull║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
