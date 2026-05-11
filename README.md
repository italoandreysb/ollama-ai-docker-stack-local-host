# Ollama em Container + Claude Code

##  PASSO 1: Subir o Ollama

```bash
# 1.1 - Salvar o docker-compose em uma pasta
mkdir -p ~/ollama-setup
cd ~/ollama-setup
# Copiar o arquivo docker-compose.yml aqui

# 1.2 - Subir o container
docker-compose -f docker-compose.yml up -d

# 1.3 - Verificar se está rodando
docker-compose -f docker-compose.yml ps
# Output esperado: ollama-server running
```

---

##  PASSO 2: Baixar um Modelo

Os melhores modelos para Claude Code (por performance/tamanho):

### Opções Recomendadas:

**1. Llama 2 (7B) - Equilibrado**
```bash
docker-compose -f docker-compose.yml exec ollama ollama pull llama2
# Tamanho: ~4GB
# Qualidade: ⭐⭐⭐⭐
# Velocidade: ⭐⭐⭐⭐
```

**2. Mistral (7B) - Rápido e bom**
```bash
docker-compose -f docker-compose.yml exec ollama ollama pull mistral
# Tamanho: ~4GB
# Qualidade: ⭐⭐⭐⭐
# Velocidade: ⭐⭐⭐⭐⭐
```

**3. Neural-Chat (7B) - Otimizado para chat**
```bash
docker-compose -f docker-compose.yml exec ollama ollama pull neural-chat
# Tamanho: ~4GB
# Qualidade: ⭐⭐⭐
# Velocidade: ⭐⭐⭐⭐⭐
```

**4. Llama 2 Uncensored (7B) - Menos restritivo**
```bash
docker-compose -f docker-compose.yml exec ollama ollama pull llama2-uncensored
# Tamanho: ~4GB
```

**5. Code Llama (7B) - Otimizado para código! ⭐**
```bash
docker-compose -f docker-compose.yml exec ollama ollama pull codellama
# Tamanho: ~4GB
# Qualidade: ⭐⭐⭐⭐ (para código)
# Velocidade: ⭐⭐⭐⭐
```

**6. Qwen 2.5 Coder (14B) - Melhor para coding**
```bash
docker-compose -f docker-compose.yml exec ollama ollama pull qwen2.5-coder
# Tamanho: ~9GB
# Qualidade: ⭐⭐⭐⭐⭐ (para código)
# Velocidade: ⭐⭐⭐
```

### Listar modelos já baixados:
```bash
docker-compose -f docker-compose.yml exec ollama ollama list
```

---

## PASSO 3: Testar o Ollama

### Test 1: Via curl
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "mistral",
  "prompt": "Olá, qual é a capital do Brasil?",
  "stream": false
}'
```

### Test 2: Entrar no container e testar
```bash
docker-compose -f docker-compose.yml exec ollama bash

# Dentro do container:
ollama run mistral "Explique IA em uma sentença"
# Ctrl+D para sair
```

---

## PASSO 4: Conectar com Claude Code

### Opção 1: Permanente (arquivo .bashrc ou .zshrc)

**Linux/Mac:**
```bash
# Adicionar ao final do ~/.bashrc ou ~/.zshrc:
export ANTHROPIC_BASE_URL="http://localhost:11434"
export ANTHROPIC_API_KEY="ollama"
export CLAUDE_MODEL="mistral"  # ou outro modelo

# Depois recarregar:
source ~/.bashrc  # ou ~/.zshrc
```

**Windows (PowerShell):**
```powershell
[Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "http://localhost:11434", "User")
[Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "ollama", "User")
[Environment]::SetEnvironmentVariable("CLAUDE_MODEL", "mistral", "User")

# Reiniciar terminal
```

### Opção 2: Temporário (para esta sessão)

```bash
export ANTHROPIC_BASE_URL="http://localhost:11434"
export ANTHROPIC_API_KEY="ollama"
export CLAUDE_MODEL="mistral"
```

### Opção 3: Criar alias (recomendado)

**Linux/Mac:**
```bash
# Adicionar ao ~/.bashrc ou ~/.zshrc:
alias claude-local='ANTHROPIC_BASE_URL="http://localhost:11434" ANTHROPIC_API_KEY="ollama" CLAUDE_MODEL="mistral" claude'

# Depois:
source ~/.bashrc  # ou ~/.zshrc

# Usar:
claude-local -p "seu prompt aqui"
```

---

##  PASSO 5: Usar Claude Code com Ollama

```bash
# Instalar Claude Code (se ainda não tem)
npm install -g @anthropic-ai/claude-code

# Usar com Ollama
claude -p "escreva um hello world em python"

# Ou com seu alias personalizado:
claude-local -p "escreva um hello world em python"
```

---

##  Comparação de Modelos

| Modelo | Tamanho | Velocidade | Qualidade | Uso Ideal |
|--------|---------|-----------|-----------|-----------|
| mistral | 4GB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Chat rápido |
| llama2 | 4GB | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Geral |
| codellama | 4GB | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **Código** |
| qwen2.5-coder | 9GB | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **Código (melhor)** |
| neural-chat | 4GB | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | Chat simples |

---

##  Comandos Úteis

```bash
# Ver logs do container
docker-compose -f docker-compose.yml logs -f ollama

# Entrar no container
docker-compose -f docker-compose.yml exec ollama bash

# Parar o Ollama
docker-compose -f docker-compose.yml stop

# Parar e remover (zera tudo)
docker-compose -f docker-compose.yml down

# Retirar o volume também (atenção: deleta modelos)
docker-compose -f docker-compose.yml down -v

# Ver uso de espaço do container
docker exec ollama du -sh /root/.ollama
```

---

##  GPU Support (NVIDIA)

Se você tem uma GPU NVIDIA e quer acelerar:

1. **Instalar nvidia-docker:**
```bash
# Ubuntu/Debian
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

2. **Descomentar no docker-compose.yml:**
```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

3. **Subir novamente:**
```bash
docker-compose -f docker-compose.yml up -d
```

4. **Verificar se GPU está sendo usada:**
```bash
docker-compose -f docker-compose.yml exec ollama nvidia-smi
```

---

##  Troubleshooting

**Problema: "Connection refused" ao conectar Claude Code**
```bash
# Verificar se está rodando:
docker-compose -f docker-compose.yml ps

# Testar a conexão:
curl http://localhost:11434/api/tags

# Se não responder, reiniciar:
docker-compose -f docker-compose.yml restart ollama
```

**Problema: Modelo muito lento**
- Trocar para um modelo menor (mistral, llama2)
- Ativar GPU se disponível
- Reduzir OLLAMA_NUM_PARALLEL

**Problema: Espaço em disco cheio**
```bash
# Ver tamanho dos modelos:
docker exec ollama du -sh /root/.ollama/*

# Remover um modelo:
docker-compose -f docker-compose.yml exec ollama ollama rm mistral
```

---

##  Resumo Rápido

```bash
# 1. Subir
docker-compose -f docker-compose.yml up -d

# 2. Baixar modelo (recomendado: mistral ou codellama)
docker-compose -f docker-compose.yml exec ollama ollama pull mistral

# 3. Configurar Claude Code
export ANTHROPIC_BASE_URL="http://localhost:11434"
export ANTHROPIC_API_KEY="ollama"

# 4. Usar Claude Code
claude -p "seu prompt aqui"
```

---

**Sucesso!  Agora você tem Claude Code rodando localmente de graça!**
