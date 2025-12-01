#!/bin/bash
set -e

echo -e "\033[1;31m\nATENÇÃO: Este script irá parar e remover TODOS os containers e redes do 'WP-Server-in-a-Box'.\033[0m"
read -p "Deseja continuar? (s/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    exit 1
fi

# Pergunta se o usuário quer apagar os dados também
read -p "Deseja também remover TODOS OS DADOS (volumes)? Esta ação é IRREVERSÍVEL. (s/N) " -n 1 -r
echo
DOWN_FLAGS=""
if [[ $REPLY =~ ^[Ss]$ ]]; then
    DOWN_FLAGS="-v"
    echo "Os volumes de dados serão removidos."
fi

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

echo "\n--- Desligando a stack do WordPress ---"
cd "$SCRIPT_DIR/wordpress-stack/"
sudo docker compose down $DOWN_FLAGS

echo "\n--- Desligando a stack do Proxy ---"
cd "$SCRIPT_DIR/proxy/"
sudo docker compose down $DOWN_FLAGS

echo "\n--- Limpando redes não utilizadas ---"
sudo docker network prune -f

echo "\n--- ✅ SUCESSO! O ambiente foi descomissionado. ---"
