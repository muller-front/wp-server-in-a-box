# Use a imagem oficial do WordPress com FPM como base.
FROM wordpress:fpm

# Adiciona um script auxiliar e poderoso para instalar extensões PHP.
# Ele resolve todas as dependências do sistema (apt-get) automaticamente.
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

# Torna o script executável
RUN chmod +x /usr/local/bin/install-php-extensions

# Usa o script para instalar nossos módulos de uma vez. Simples e limpo.
RUN install-php-extensions imagick intl
