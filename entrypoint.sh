#!/bin/sh

set -e

export HOME="/github/workspace"
export NVM_DIR="/github/workspace/nvm"
export WRANGLER_HOME="/github/workspace"
export PATH="$HOME/.cargo/bin:$PATH"

# h/t https://github.com/elgohr/Publish-Docker-Github-Action
sanitize() {
  if [ -z "${1}" ]
  then
    >&2 echo "Unable to find ${2}. Did you add a GitHub secret called key ${2}, and pass in secrets.${2} in your workflow?"
    exit 1
  fi
}

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh | bash
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

mkdir -p "$HOME/.wrangler"
chmod -R 770 "$HOME/.wrangler"

sanitize "${INPUT_EMAIL}" "email"
sanitize "${INPUT_APIKEY}" "apiKey"

export CF_EMAIL="$INPUT_EMAIL"
export CF_API_KEY="$INPUT_APIKEY"

cd $HOME

npm i -g @cloudflare/wrangler 
npm i -D wasm-pack-npm 

npm i 
npm install babel-core babel-loader babel-preset-es2015 --save-dev
npm i -D babel babel-cli inquirer eslint --save-dev 

npm i -g webpack 
npm i -D webpack-cli 
npm i -D workbox-cli --save-dev

npm i -g @webpack-cli/init 



wrangler whoami

webpack -v

npx workbox generateSW workbox-config.js


npm run publish
