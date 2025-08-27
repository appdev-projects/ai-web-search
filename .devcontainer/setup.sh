#!/bin/bash
set -e

echo "Setting up development environment..."

# Install dependencies
bundle install
yarn install || npm install

# Setup database
echo "Setting up database..."
until PGPASSWORD=postgres psql -h db -U postgres -c '\q' 2>/dev/null; do
  echo "Waiting for PostgreSQL to be ready..."
  sleep 2
done

# Create and migrate database
bin/rails db:create db:migrate db:seed || true

# Install additional gems
gem install rufo htmlbeautifier solargraph

# Configure Git
git config --global push.default upstream
git config --global merge.ff only
git config --global alias.aa '!git add -A'
git config --global alias.cm '!f(){ git commit -m "${*}"; };f'
git config --global alias.acm '!f(){ git add -A && git commit -am "${*}"; };f'
git config --global alias.as '!git add -A && git stash'
git config --global alias.p 'push'
git config --global alias.sla 'log --oneline --decorate --graph --all'
git config --global alias.co 'checkout'
git config --global alias.cob 'checkout -b'
git config --global --add --bool push.autoSetupRemote true
git config --global core.editor "code --wait"

# Add bash aliases
cat >> ~/.bashrc << 'EOF'

# Rails aliases
alias be='bundle exec'
alias grade='rake grade'
alias grade:reset_token='rake grade:reset_token'

# Git function
g() {
  if [[ $# > 0 ]]; then
    git $@
  else
    git status
  fi
}

# Add bin to PATH
export PATH="$PWD/bin:$PATH"

# Database configuration
export DB_HOST="db"
export DB_USERNAME="postgres"
export DB_PASSWORD="postgres"
export DB_PORT="5432"
export RAILS_ENV="development"

# Auto-start Redis if needed
if command -v redis-server &> /dev/null; then
  redis-server --daemonize yes 2>/dev/null || true
fi
EOF

echo "Development environment setup complete!"