#!/bin/bash
# =======================================================
# Script de instalação automática do NovoSGA via Docker
# Compatível com Ubuntu Server 20.04, 22.04 e 24.04 LTS
# =======================================================

echo "🚀 Iniciando instalação do NovoSGA + Docker..."

# Atualiza pacotes
sudo apt update -y
sudo apt upgrade -y

# Instala dependências
sudo apt install -y ca-certificates curl gnupg lsb-release

# Verifica se Docker está instalado
if ! command -v docker &> /dev/null
then
    echo "🐳 Docker não encontrado. Instalando..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo systemctl enable docker
    sudo systemctl start docker
    echo "✅ Docker instalado com sucesso!"
else
    echo "🐳 Docker já está instalado, continuando..."
fi

# Cria rede Docker (se não existir)
docker network inspect novosga_net >/dev/null 2>&1 || docker network create novosga_net

# Inicia serviço Mercure
echo "⚙️  Iniciando serviço Mercure..."
docker run -d \
  --name novosga_mercure \
  --network novosga_net \
  -p 3000:3000 \
  -e 'SERVER_NAME=:3000' \
  -e 'MERCURE_PUBLISHER_JWT_KEY=!ChangeThisMercureHubJWTSecretKey!' \
  -e 'MERCURE_EXTRA_DIRECTIVES=anonymous 1; cors_origins *' \
  novosga/mercure:v0.11

# Inicia aplicação base do NovoSGA
echo "⚙️  Iniciando aplicação NovoSGA..."
docker run -d \
  --name novosga_app \
  --network novosga_net \
  -p 80:8080 \
  -e DATABASE_URL="mysql://novosga:MySQL_App_P4ssW0rd@mysqldb:3306/novosga2?charset=utf8mb4&serverVersion=5.7" \
  -e MERCURE_JWT_SECRET="!ChangeThisMercureHubJWTSecretKey!" \
  -e MERCURE_URL="http://mercure:3000/.well-known/mercure" \
  -e MERCURE_PUBLIC_URL="http://127.0.0.1:3000/.well-known/mercure" \
  novosga/novosga:2.2-standalone

echo "🎉 Instalação concluída!"
echo "👉 Acesse o NovoSGA em: http://$(hostname -I | awk '{print $1}')"
echo "👉 O serviço Mercure roda na porta 3000"
