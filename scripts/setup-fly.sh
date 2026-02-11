#!/usr/bin/env bash
set -euo pipefail

# First-time Fly.io setup for the production app template.
# Creates the app, sets secrets, scales to 2 regions, and deploys.

APP_NAME=""
REGIONS=("yyz" "sea")

# Secrets to read from .env or prompt for
SECRET_NAMES=(
  DATABASE_URL
  VITE_SUPABASE_URL
  VITE_SUPABASE_ANON_KEY
  SUPABASE_SERVICE_ROLE_KEY
  APP_URL
  COOKIE_SECRET
  RESEND_API_KEY
  STORAGE_ACCESS_KEY_ID
  STORAGE_SECRET_ACCESS_KEY
  STORAGE_REGION
  SUPABASE_PROJECT_ID
  HONEYPOT_SECRET
  STRIPE_SECRET_KEY
  STRIPE_WEBHOOK_SECRET
  HYPERDX_API_KEY
  HYPERDX_SERVICE_NAME
)

info() { printf "\033[1;34m→\033[0m %s\n" "$1"; }
success() { printf "\033[1;32m✓\033[0m %s\n" "$1"; }
error() { printf "\033[1;31m✗\033[0m %s\n" "$1" >&2; exit 1; }

# 1. Check flyctl
command -v flyctl >/dev/null 2>&1 || error "flyctl not found. Install: https://fly.io/docs/flyctl/install/"
success "flyctl found"

# 2. Choose app name
read -rp "App name (default: production-app-template): " APP_NAME
APP_NAME="${APP_NAME:-production-app-template}"

# 3. Create app
info "Creating app '$APP_NAME'..."
flyctl apps create "$APP_NAME" || true

# Update fly.toml with chosen name
if [ -f fly.toml ]; then
  sed -i.bak "s/^app = .*/app = \"$APP_NAME\"/" fly.toml && rm -f fly.toml.bak
  success "Updated fly.toml with app name"
fi

# 4. Set secrets
info "Setting secrets from .env (or prompting)..."
declare -A secrets

for name in "${SECRET_NAMES[@]}"; do
  value=""
  if [ -f .env ]; then
    value=$(grep -E "^${name}=" .env 2>/dev/null | head -1 | cut -d'=' -f2- | sed 's/^"//;s/"$//')
  fi
  if [ -z "$value" ]; then
    read -rp "  $name: " value
  else
    read -rp "  $name [$value]: " input
    value="${input:-$value}"
  fi
  if [ -n "$value" ]; then
    secrets["$name"]="$value"
  fi
done

# Build secrets string
secret_args=""
for name in "${!secrets[@]}"; do
  secret_args+="$name=${secrets[$name]} "
done

if [ -n "$secret_args" ]; then
  flyctl secrets set --app "$APP_NAME" $secret_args
  success "Secrets set"
fi

# 5. Scale to 2 regions
info "Scaling to ${#REGIONS[@]} regions: ${REGIONS[*]}..."
for region in "${REGIONS[@]}"; do
  flyctl scale count 1 --region "$region" --app "$APP_NAME" --yes || true
done
success "Scaled to ${#REGIONS[@]} regions"

# 6. Set machine size
info "Setting machine size to shared-cpu-1x 256MB..."
flyctl scale vm shared-cpu-1x --memory 256 --app "$APP_NAME" || true
success "Machine size set"

# 7. Deploy
info "Deploying..."
flyctl deploy --app "$APP_NAME"
success "Deployed!"

# 8. Print GitHub Actions setup
printf "\n\033[1;33m──────────────────────────────────────────\033[0m\n"
info "To enable auto-deploy from CI:"
echo "  1. Create a deploy token:  flyctl tokens create deploy --app $APP_NAME"
echo "  2. Add it as a GitHub secret named FLY_API_TOKEN"
echo "     gh secret set FLY_API_TOKEN --body <token>"
printf "\033[1;33m──────────────────────────────────────────\033[0m\n"
