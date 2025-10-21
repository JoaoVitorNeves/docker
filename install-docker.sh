#!/bin/bash
# ===============================================
# Instalação automática do Docker no Ubuntu Server
# Compatível com Ubuntu 20.04, 22.04 e 24.04 LTS
# ===============================================

echo "🚀 Iniciando instalação do Docker..."

# Atualiza pacotes
sudo apt update -y
sudo apt upgrade -y

# Remove versões antigas
sudo apt remove -y docker docker-engine docker.io containerd runc

# Instala dependências
sudo apt install -y ca-certificates curl gnupg lsb-release

# Adiciona chave GPG oficial do Docker
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Adiciona repositório Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualiza pacotes novamente
sudo apt update -y

# Instala Docker e plugins
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Inicia e habilita Docker
sudo systemctl enable docker
sudo systemctl start docker

# Adiciona usuário atual ao grupo docker
sudo usermod -aG docker $USER

# Testa instalação
echo "✅ Testando instalação do Docker..."
docker_version=$(docker --version 2>/dev/null)
if [ $? -eq 0 ]; then
  echo "✔ Docker instalado com sucesso: $docker_version"
else
  echo "⚠ Docker foi instalado, mas requer reinício da sessão para aplicar permissões."
fi

# Mensagem final
echo ""
echo "🎉 Instalação concluída!"
echo "👉 Saia e entre novamente no sistema para aplicar permissões do grupo docker."
echo "👉 Teste com: docker run hello-world"
