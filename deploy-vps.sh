#!/bin/bash
# Deploy da landing page no VPS
# Uso: ./deploy-vps.sh usuario@ip-do-vps

set -e

VPS="${1:-root@seu-vps-ip}"
REMOTE_DIR="/var/www/multicelllojas"

echo "🚀 Deploy multicelllojas.com.br para $VPS"

# Sync files
echo "📦 Enviando arquivos..."
ssh "$VPS" "mkdir -p $REMOTE_DIR"
rsync -avz --exclude='.git' --exclude='node_modules' --exclude='deploy-vps.sh' --exclude='nginx.conf' --exclude='vercel.json' --exclude='netlify.toml' \
  ./ "$VPS:$REMOTE_DIR/"

# Copy nginx config
echo "⚙️ Configurando nginx..."
scp nginx.conf "$VPS:/etc/nginx/sites-available/multicelllojas"
ssh "$VPS" "ln -sf /etc/nginx/sites-available/multicelllojas /etc/nginx/sites-enabled/ && nginx -t && systemctl reload nginx"

# Setup SSL with certbot
echo "🔒 Configurando SSL..."
ssh "$VPS" "certbot --nginx -d multicelllojas.com.br -d www.multicelllojas.com.br --non-interactive --agree-tos -m diegomulticell@hotmail.com || echo 'Certbot: verifique se o DNS está apontando para o VPS'"

echo "✅ Deploy concluído! https://multicelllojas.com.br"
