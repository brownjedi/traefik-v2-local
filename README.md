# Traefik v2 for local https development

this repo will setup local Traefik web proxy with DNS resolution on all **\*.dev.local** domains and uses [mkcert](https://github.com/FiloSottile/mkcert) to create a trusted Root CA and TLS certificates for using https in development.

## 0. Install prerequisites

- [Docker](https://docs.docker.com/docker-for-mac/install/)
- [Homebrew](https://brew.sh/)

## 1. Setup resolver

```sh
# Setup MacOS to take into account our local docker resolver
sudo mkdir -p /etc/resolver
echo "nameserver 127.0.0.1" | sudo tee -a /etc/resolver/dev.local > /dev/null
```

## 2. Setup a local Root CA using mkcert

```sh
brew install mkcert
brew install nss # only if you use Firefox

# Setup the local Root CA
mkcert -install
```

## 3. Setup a global traefik container with secured dashboard

```sh
# Clone this repository
git clone https://github.com/saikarthikreddyginni/traefik-v2-local.git ~/traefik
cd ~/traefik

# Create a local TLS certificate
# *.dev.local will create a wildcard certificate so any subdomain under it will also work.
mkcert -cert-file certs/local-cert.pem -key-file certs/local-key.pem "dev.local" "*.dev.local"

# Create a username and password to access the traefik dashboard
htpasswd -nb <username> <password> >> credentials.txt

# Start Traefik
./start.sh

# Go on https://traefik.dev.local/dashboard/ you should have the traefik web dashboard serve over https
```

## 4. Setup your dev containers

```sh
# On your docker-compose.yaml file

# Add the external network proxy at the end of the file
networks:
  proxy:
    external: true

# Bind each exposed container to the proxy network
  networks:
    - proxy

# Add these labels on the container (change the <my-app> and <port> to your app name and port)
  labels:
    traefik.enable: true
    traefik.http.routers.<my-app>.entrypoints: websecure
    traefik.http.routers.<my-app>.rule: Host(`<my-app>.dev.local`)
    traefik.http.routers.<my-app>.tls: true
    traefik.http.routers.<my-app>.middlewares: secured@file # this adds default headers and ip whitelisting
    traefik.http.services.<my-app>.loadbalancer.server.port: <port>

# For web applications, use the same origin domain for your frontend and backend to
# avoid cookies sharing issues.
# By example: https://dev.local (frontend) and https://api.dev.local (backend)
```
