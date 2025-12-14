#!/bin/bash

# Script para instalar regras de desenvolvimento do repositório vibe-coding-rules
# Uso: ./install-rules.sh [caminho-do-projeto]

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretório do repositório de regras (onde este script está)
RULES_REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo -e "${BLUE}🚀 Instalando regras de desenvolvimento...${NC}\n"

# Verificar se o diretório de destino existe
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}⚠️  Diretório não encontrado: $TARGET_DIR${NC}"
    exit 1
fi

# Criar estrutura de diretórios
echo -e "${BLUE}📁 Criando estrutura de diretórios...${NC}"
mkdir -p "$TARGET_DIR/.cursor/rules/taskmaster"
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.taskmaster/templates"
mkdir -p "$TARGET_DIR/.taskmaster/tasks"

# Copiar regras do Cursor
echo -e "${BLUE}📋 Copiando regras do Cursor...${NC}"
if [ -d "$RULES_REPO_DIR/.cursor/rules" ]; then
    cp -r "$RULES_REPO_DIR/.cursor/rules/"* "$TARGET_DIR/.cursor/rules/"
    echo -e "${GREEN}✅ Regras do Cursor copiadas${NC}"
else
    echo -e "${YELLOW}⚠️  Diretório .cursor/rules não encontrado no repositório de regras${NC}"
fi

# Copiar configuração MCP (sempre sobrescreve)
echo -e "${BLUE}⚙️  Copiando configuração MCP...${NC}"
if [ -f "$RULES_REPO_DIR/.cursor/mcp.json.example" ]; then
    cp "$RULES_REPO_DIR/.cursor/mcp.json.example" "$TARGET_DIR/.cursor/mcp.json"
    echo -e "${GREEN}✅ Configuração MCP copiada (edite e adicione suas API keys)${NC}"
elif [ -f "$RULES_REPO_DIR/.mcp.json" ]; then
    # Fallback para o formato antigo
    cp "$RULES_REPO_DIR/.mcp.json" "$TARGET_DIR/.cursor/mcp.json"
    echo -e "${GREEN}✅ Configuração MCP copiada${NC}"
fi

# Criar .gitignore se não existir ou atualizar
echo -e "${BLUE}📝 Atualizando .gitignore...${NC}"
if [ ! -f "$TARGET_DIR/.gitignore" ]; then
    # Criar .gitignore básico se não existir
    touch "$TARGET_DIR/.gitignore"
    echo -e "${GREEN}✅ .gitignore criado${NC}"
fi

# Adicionar configs de forma discreta ao final do arquivo (sem comentários óbvios)
if ! grep -q "^CLAUDE\.md$" "$TARGET_DIR/.gitignore" 2>/dev/null; then
    echo "" >> "$TARGET_DIR/.gitignore"
    echo "# Local configuration" >> "$TARGET_DIR/.gitignore"
    echo ".env" >> "$TARGET_DIR/.gitignore"
    echo ".env.local" >> "$TARGET_DIR/.gitignore"
    echo ".mcp.json" >> "$TARGET_DIR/.gitignore"
    echo "CLAUDE.md" >> "$TARGET_DIR/.gitignore"
    echo "" >> "$TARGET_DIR/.gitignore"
    echo "# IDE and tools" >> "$TARGET_DIR/.gitignore"
    echo ".claude/" >> "$TARGET_DIR/.gitignore"
    echo ".cursor/mcp.json" >> "$TARGET_DIR/.gitignore"
    echo ".cursor/rules/*.local.mdc" >> "$TARGET_DIR/.gitignore"
    echo "" >> "$TARGET_DIR/.gitignore"
    echo "# Task management" >> "$TARGET_DIR/.gitignore"
    echo ".taskmaster/tasks/" >> "$TARGET_DIR/.gitignore"
    echo ".taskmaster/state.json" >> "$TARGET_DIR/.gitignore"
    echo ".taskmaster/config.json" >> "$TARGET_DIR/.gitignore"
    echo ".taskmaster/CLAUDE.md" >> "$TARGET_DIR/.gitignore"
    echo ".taskmaster/docs/" >> "$TARGET_DIR/.gitignore"
    echo ".taskmaster/reports/" >> "$TARGET_DIR/.gitignore"
    echo -e "${GREEN}✅ Configurações adicionadas ao .gitignore${NC}"
fi

# Copiar configuração do Claude Code
echo -e "${BLUE}🤖 Configurando Claude Code...${NC}"
if [ -d "$RULES_REPO_DIR/.claude" ]; then
    cp -r "$RULES_REPO_DIR/.claude/"* "$TARGET_DIR/.claude/" 2>/dev/null || true
    echo -e "${GREEN}✅ Configurações do Claude Code copiadas${NC}"
fi

# Copiar .mcp.json para raiz (Claude Code - sempre sobrescreve)
if [ -f "$RULES_REPO_DIR/.mcp.json" ]; then
    cp "$RULES_REPO_DIR/.mcp.json" "$TARGET_DIR/.mcp.json"
    echo -e "${GREEN}✅ .mcp.json copiado para raiz (Claude Code)${NC}"
fi

# Copiar templates do Taskmaster
echo -e "${BLUE}📋 Configurando Taskmaster...${NC}"
if [ -d "$RULES_REPO_DIR/.taskmaster" ]; then
    # Copiar templates
    if [ -d "$RULES_REPO_DIR/.taskmaster/templates" ]; then
        cp -r "$RULES_REPO_DIR/.taskmaster/templates/"* "$TARGET_DIR/.taskmaster/templates/" 2>/dev/null || true
    fi

    # Copiar config.json.example (sempre sobrescreve)
    if [ -f "$RULES_REPO_DIR/.taskmaster/config.json.example" ]; then
        cp "$RULES_REPO_DIR/.taskmaster/config.json.example" "$TARGET_DIR/.taskmaster/config.json"
        echo -e "${GREEN}✅ Configuração do Taskmaster criada (Claude como padrão)${NC}"
    fi

    # Copiar CLAUDE.md do Taskmaster (sempre sobrescreve)
    if [ -f "$RULES_REPO_DIR/.taskmaster/CLAUDE.md.example" ]; then
        cp "$RULES_REPO_DIR/.taskmaster/CLAUDE.md.example" "$TARGET_DIR/.taskmaster/CLAUDE.md"
    fi

    echo -e "${GREEN}✅ Templates do Taskmaster copiados${NC}"
fi

# Copiar .env.example (sempre sobrescreve)
if [ -f "$RULES_REPO_DIR/.env.example" ]; then
    cp "$RULES_REPO_DIR/.env.example" "$TARGET_DIR/.env"
    echo -e "${GREEN}✅ .env criado (adicione suas API keys)${NC}"
fi

# Copiar CLAUDE.md (sempre sobrescreve)
echo -e "${BLUE}📄 Copiando CLAUDE.md...${NC}"
if [ -f "$RULES_REPO_DIR/CLAUDE.md" ]; then
    cp "$RULES_REPO_DIR/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
    echo -e "${GREEN}✅ CLAUDE.md copiado${NC}"
fi

echo -e "\n${GREEN}✨ Instalação concluída!${NC}\n"
echo -e "${BLUE}📚 Próximos passos:${NC}"
echo -e "   ${GREEN}✓${NC} Cursor rules instaladas"
echo -e "   ${GREEN}✓${NC} Claude Code configurado"
echo -e "   ${GREEN}✓${NC} Taskmaster templates prontos"
echo -e "   ${GREEN}✓${NC} Claude configurado como modelo padrão\n"
echo -e "${BLUE}🔧 Configuração necessária:${NC}"
echo -e "   1. ${YELLOW}Edite .env e adicione suas API keys:${NC}"
echo -e "      - ANTHROPIC_API_KEY"
echo -e "      - PERPLEXITY_API_KEY"
echo -e "   2. ${YELLOW}Atualize .mcp.json e .cursor/mcp.json com as mesmas keys${NC}"
echo -e "   3. ${YELLOW}Reinicie o Cursor${NC} para carregar o MCP server\n"
echo -e "${BLUE}🚀 Pronto para usar:${NC}"
echo -e "   • ${GREEN}Cursor${NC}: Regras ativas automaticamente"
echo -e "   • ${GREEN}Claude Code${NC}: Configurado via .mcp.json"
echo -e "   • ${GREEN}Taskmaster${NC}: Claude como modelo padrão (coding, research, planning)\n"
echo -e "${BLUE}📖 Templates incluídos:${NC}"
echo -e "   • PRD exemplo: .taskmaster/templates/prd-example.md"
echo -e "   • Comandos Claude: .claude/commands/taskmaster.md\n"

