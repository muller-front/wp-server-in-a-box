#!/bin/bash
set -e

# ==================================================================================
# SCRIPT DE CONFIGURAÇÃO DE URL (HTTP)
#
# O que faz:
# 1. Pergunta ao usuário qual IP ou domínio ele quer usar.
# 2. Remove quaisquer definições antigas de WP_HOME/WP_SITEURL no wp-config.php.
# 3. Insere as novas definições (com http://) no local correto.
# 4. Corrige as permissões do arquivo, caso tenham sido alteradas.
# ==================================================================================

echo "--- Script de Configuração de URL (HTTP) para wp-config.php ---"

# Detecta o diretório onde o script está para portabilidade
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
CONFIG_FILE="$SCRIPT_DIR/wordpress-stack/wordpress/wp-config.php"
CONFIG_DIR="$SCRIPT_DIR/wordpress-stack/wordpress"

# 1. Verificar se o wp-config.php existe
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "\033[1;31mERRO: O arquivo '$CONFIG_FILE' não foi encontrado.\033[0m"
    echo "Por favor, acesse o site e complete a instalação do WordPress primeiro."
    exit 1
fi

# 2. Perguntar ao usuário o IP ou Domínio
read -p "Digite o IP ou domínio para usar (ex: 52.14.227.36 ou seuteste.com): " DOMAIN_OR_IP

# 3. Validar a entrada
if [ -z "$DOMAIN_OR_IP" ]; then
    echo -e "\033[1;31mNenhuma entrada detectada. Saindo.\033[0m"
    exit 1
fi

# 4. Formatar a URL
# O 'tr' remove http:// ou https:// caso o usuário tenha digitado por engano
CLEAN_DOMAIN=$(echo "$DOMAIN_OR_IP" | sed -e 's,https://,,g' -e 's,http://,,g')
FULL_URL="http://$CLEAN_DOMAIN"

echo "Configurando o site para rodar em: $FULL_URL"

# 5. Salvar o dono e grupo originais do arquivo
# Isso é crucial, pois 'sudo sed' pode alterar o dono para 'root'
ORIGINAL_OWNER=$(stat -c '%U' "$CONFIG_FILE")
ORIGINAL_GROUP=$(stat -c '%G' "$CONFIG_FILE")

# 6. Remover definições antigas (para o script ser 'idempotente')
echo "Limpando definições antigas de URL (se existirem)..."
# Usamos 'sudo sed' pois o arquivo pode pertencer ao www-data
sudo sed -i "/define( *'WP_HOME'/d" "$CONFIG_FILE"
sudo sed -i "/define( *'WP_SITEURL'/d" "$CONFIG_FILE"

# 7. Adicionar as novas definições antes da linha "/* That's all..."
echo "Inserindo novas definições no wp-config.php..."
sudo sed -i "/\/\* That's all, stop editing!/i \
define( 'WP_HOME', '$FULL_URL' );\n\
define( 'WP_SITEURL', '$FULL_URL' );\n" "$CONFIG_FILE"

# 8. Restaurar as permissões e o dono corretos
echo "Restaurando permissões originais ($ORIGINAL_OWNER:$ORIGINAL_GROUP)..."
sudo chown $ORIGINAL_OWNER:$ORIGINAL_GROUP "$CONFIG_FILE"
sudo chmod 644 "$CONFIG_FILE"

echo ""
echo "--- ✅ SUCESSO! ---"
echo "O arquivo wp-config.php foi atualizado."
echo "Seu site agora deve responder em: $FULL_URL"
echo "(Lembre-se de limpar o cache do seu navegador ou usar uma janela anônima)"
