#!/bin/bash
set -e

echo "--- Iniciando o script de provisionamento/atualização do 'WP-Server-in-a-Box' ---"

# Detecta o diretório onde o script está para portabilidade
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
echo "Diretório do projeto detectado: $SCRIPT_DIR"

# Verifica se o arquivo .env existe
ENV_FILE="$SCRIPT_DIR/.env"
if [ ! -f "$ENV_FILE" ]; then
    echo -e "\033[1;31mERRO: Arquivo .env não encontrado!\033[0m"
    echo "Por favor, copie .env.example para .env e preencha suas senhas."
    exit 1
fi

# ==================================================================================
# SEÇÃO DE INSTALAÇÃO DO DOCKER (IDEMPOTENTE)
# ==================================================================================
if ! command -v docker &> /dev/null
then
    echo "--- Docker não encontrado. Iniciando instalação... ---"
    echo "--- Passo 1: Removendo versões antigas do Docker (se houver) ---"
    sudo apt-get remove docker docker-engine docker.io containerd runc -y || true

    echo "--- Passo 2: Atualizando o sistema e instalando dependências ---"
    sudo apt-get update && sudo apt-get upgrade -y
    sudo apt-get install -y ca-certificates curl gnupg unzip

    echo "--- Passo 3: Adicionando o repositório oficial do Docker ---"
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    echo "--- Passo 4: Instalando o Docker Engine e o Compose V2 ---"
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
else
    echo "--- Docker já está instalado. Pulando instalação. ---"
fi

echo "--- Verificando instalações ---"
docker --version
docker compose version

# ==================================================================================
# SEÇÃO DE ORQUESTRAÇÃO DOS CONTAINERS
# ==================================================================================

# Lista das stacks a serem gerenciadas
STACKS=("proxy" "wordpress-stack")

for stack in "${STACKS[@]}"; do
    echo -e "\n--- Processando a stack: $stack ---"
    STACK_PATH="$SCRIPT_DIR/$stack"

    if [ -d "$STACK_PATH" ]; then
        cd "$STACK_PATH"

        # Lógica de atualização/criação
        if [ "$stack" == "wordpress-stack" ]; then
            echo "=> Verificando/Atualizando a stack do WordPress (com build)..."
            sudo docker compose --env-file "$ENV_FILE" up -d --build
        else
            echo "=> Verificando/Atualizando a stack do Proxy..."
            sudo docker compose pull
            sudo docker compose up -d
        fi
    else
        echo "AVISO: Diretório '$STACK_PATH' não encontrado. Pulando."
    fi
done

echo -e "\n--- Limpando imagens antigas do Docker ---"
sudo docker image prune -f

echo ""
echo "--- ✅ SUCESSO! ---"
echo "O ambiente do WordPress foi provisionado/atualizado."
echo "Se esta for a primeira execução, siga os passos manuais abaixo:"
echo "1. Configure o Nginx Proxy Manager no IP_DA_VM:81"
echo "   (user: admin@example.com / senha: changeme)"
echo "2. Crie um registro DNS (ex: seudominio.com) apontando para o IP desta VM."
echo "3. No NPM, adicione um Proxy Host para 'seudominio.com':"
echo "   - Na aba 'Details', use 'Forward Hostname / IP' como 'wp_nginx' na porta 80."
echo "   - Ative também a opção 'Block Common Exploits'."
echo "   - Na aba 'SSL', solicite um certificado e ative 'Force SSL' e 'HTTP/2 Support'."
echo "4. Acesse 'https://seudominio.com' e complete a famosa instalação de 5 minutos do WordPress."
echo "5. (Opcional) Para restaurar um backup, instale seu plugin de migração (como o WPVivid) e siga as instruções dele."

