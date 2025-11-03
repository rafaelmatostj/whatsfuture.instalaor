#######################################
# updates frontend code
# Arguments:
#   None
#######################################
backend_nginx_setup() {
  print_banner
  printf "${WHITE} 💻 Configurando nginx (backend)...${GRAY_LIGHT}"
  printf "\n\n"

  sleep 2

  backend_hostname=$(echo "${backend_url/https:\/\/}")

sudo su - root << EOF

cat > /etc/nginx/sites-available/${nome_instancia}-backend << END
server {
  server_name $backend_hostname;

  location / {
    proxy_pass http://127.0.0.1:${backend_porta};
    proxy_http_version 1.1;

    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;

    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;

    # timeout extendido para conexões websocket
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
  }

  # Redirect HTTP -> HTTPS
  listen 80;
  listen [::]:80;
  return 301 https://\$host\$request_uri;
}

server {
  listen 443 ssl http2;
  listen [::]:443 ssl http2;
  server_name $backend_hostname;

  ssl_certificate /etc/letsencrypt/live/$backend_hostname/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/$backend_hostname/privkey.pem;

  location / {
    proxy_pass http://127.0.0.1:${backend_porta};
    proxy_http_version 1.1;

    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \$connection_upgrade;

    proxy_set_header Host \$host;
    proxy_set_header X-Real-IP \$remote_addr;
    proxy_set_header X-Forwarded-Proto \$scheme;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_cache_bypass \$http_upgrade;

    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
  }
}
END

ln -sf /etc/nginx/sites-available/${nome_instancia}-backend /etc/nginx/sites-enabled/${nome_instancia}-backend
nginx -t && systemctl restart nginx

EOF

  sleep 2
}
