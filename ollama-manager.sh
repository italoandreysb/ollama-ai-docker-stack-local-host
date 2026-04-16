#!/bin/bash

# Script para gerenciar Ollama com Docker Compose
# Uso: ./ollama-manager.sh [comando]

set -e

COMPOSE_FILE="docker-compose.yml"
CONTAINER="ollama-server"

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Função para printar com cor
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar se docker-compose existe
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null; then
        print_error "docker-compose não está instalado!"
        exit 1
    fi
}

# Comando: start
cmd_start() {
    print_info "Iniciando Ollama..."
    docker-compose -f $COMPOSE_FILE up -d
    sleep 3
    
    # Verificar se está rodando
    if docker-compose -f $COMPOSE_FILE ps | grep -q "running"; then
        print_success "Ollama iniciado com sucesso!"
        print_info "Acesso disponível em: http://localhost:11434"
    else
        print_error "Falha ao iniciar Ollama"
        exit 1
    fi
}

# Comando: stop
cmd_stop() {
    print_info "Parando Ollama..."
    docker-compose -f $COMPOSE_FILE stop
    print_success "Ollama parado"
}

# Comando: restart
cmd_restart() {
    print_info "Reiniciando Ollama..."
    cmd_stop
    sleep 2
    cmd_start
}

# Comando: status
cmd_status() {
    print_info "Status do Ollama:"
    docker-compose -f $COMPOSE_FILE ps
}

# Comando: logs
cmd_logs() {
    print_info "Exibindo logs (Ctrl+C para sair)..."
    docker-compose -f $COMPOSE_FILE logs -f ollama
}

# Comando: pull
cmd_pull() {
    if [ -z "$1" ]; then
        print_error "Uso: $0 pull [modelo]"
        echo "Modelos disponíveis:"
        echo "  - mistral"
        echo "  - llama2"
        echo "  - codellama"
        echo "  - neural-chat"
        echo "  - qwen2.5-coder"
        echo "  - phi"
        echo "  - orca-mini"
        exit 1
    fi
    
    print_info "Baixando modelo: $1"
    docker-compose -f $COMPOSE_FILE exec ollama ollama pull $1
    print_success "Modelo $1 baixado com sucesso!"
}

# Comando: list
cmd_list() {
    print_info "Modelos disponíveis:"
    docker-compose -f $COMPOSE_FILE exec ollama ollama list
}

# Comando: run
cmd_run() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        print_error "Uso: $0 run [modelo] [prompt]"
        exit 1
    fi
    
    print_info "Executando com modelo: $1"
    docker-compose -f $COMPOSE_FILE exec ollama ollama run $1 "$2"
}

# Comando: shell
cmd_shell() {
    print_info "Entrando no container..."
    docker-compose -f $COMPOSE_FILE exec ollama bash
}

# Comando: test
cmd_test() {
    print_info "Testando conexão com Ollama..."
    
    if curl -s http://localhost:11434/api/tags > /dev/null; then
        print_success "Ollama está respondendo!"
        print_info "Modelos carregados:"
        curl -s http://localhost:11434/api/tags | python3 -m json.tool 2>/dev/null || curl -s http://localhost:11434/api/tags
    else
        print_error "Ollama não está respondendo!"
        print_info "Verifique se está rodando: $0 status"
        exit 1
    fi
}

# Comando: claude-setup
cmd_claude_setup() {
    print_info "Configurando variáveis de ambiente para Claude Code..."
    
    if [ -z "$1" ]; then
        MODEL="mistral"
        print_warning "Modelo não especificado, usando: $MODEL"
    else
        MODEL=$1
    fi
    
    print_info "Adicionando ao ~/.bashrc..."
    cat >> ~/.bashrc << EOF

# Ollama + Claude Code
export ANTHROPIC_BASE_URL="http://localhost:11434"
export ANTHROPIC_API_KEY="ollama"
export CLAUDE_MODEL="$MODEL"
EOF
    
    print_info "Adicionando ao ~/.zshrc..."
    cat >> ~/.zshrc << EOF

# Ollama + Claude Code
export ANTHROPIC_BASE_URL="http://localhost:11434"
export ANTHROPIC_API_KEY="ollama"
export CLAUDE_MODEL="$MODEL"
EOF
    
    print_success "Ambiente configurado!"
    print_info "Recarregue seu shell com: source ~/.bashrc (ou ~/.zshrc)"
    print_info "Depois teste com: claude -p 'olá'"
}

# Comando: clean
cmd_clean() {
    print_warning "Isso vai remover todos os containers e volumes de Ollama!"
    read -p "Tem certeza? (s/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        print_info "Removendo containers e volumes..."
        docker-compose -f $COMPOSE_FILE down -v
        print_success "Limpeza concluída!"
    else
        print_info "Operação cancelada"
    fi
}

# Comando: help
cmd_help() {
    cat << EOF
${BLUE}🐳 Ollama Manager Script${NC}

${GREEN}Uso:${NC}
    ./ollama-manager.sh [comando] [opções]

${GREEN}Comandos:${NC}
    start              Iniciar o Ollama
    stop               Parar o Ollama
    restart            Reiniciar o Ollama
    status             Ver status
    logs               Ver logs em tempo real (Ctrl+C para sair)
    
    pull [modelo]      Baixar um modelo
    list               Listar modelos baixados
    run [modelo] [txt] Executar prompt com um modelo
    test               Testar conexão
    
    shell              Entrar no container
    claude-setup [mod] Configurar Claude Code com Ollama
    
    clean              Remover tudo (cuidado!)
    help               Mostrar esta ajuda

${GREEN}Exemplos:${NC}
    ./ollama-manager.sh start
    ./ollama-manager.sh pull mistral
    ./ollama-manager.sh list
    ./ollama-manager.sh run mistral "Olá, tudo bem?"
    ./ollama-manager.sh claude-setup mistral
    ./ollama-manager.sh logs

${GREEN}Modelos populares:${NC}
    - mistral (rápido e bom)
    - llama2 (versátil)
    - codellama (otimizado para código)
    - qwen2.5-coder (melhor para código)
    - neural-chat (rápido)

EOF
}

# Main
check_docker_compose

case "${1:-help}" in
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    status)
        cmd_status
        ;;
    logs)
        cmd_logs
        ;;
    pull)
        cmd_pull "$2"
        ;;
    list)
        cmd_list
        ;;
    run)
        cmd_run "$2" "$3"
        ;;
    test)
        cmd_test
        ;;
    shell)
        cmd_shell
        ;;
    claude-setup)
        cmd_claude_setup "$2"
        ;;
    clean)
        cmd_clean
        ;;
    help)
        cmd_help
        ;;
    *)
        print_error "Comando desconhecido: $1"
        cmd_help
        exit 1
        ;;
esac
