#!/usr/bin/env bash

set -ex

setup_coc() {
  # for neovim
  mkdir -p ~/.local/share/nvim/site/pack/coc/start
  pushd ~/.local/share/nvim/site/pack/coc/start
  curl --fail -L https://github.com/neoclide/coc.nvim/archive/release.tar.gz|tar xzfv -
  popd
}

install_coc_extensions() {
  # Install extensions
  mkdir -p ~/.config/coc/extensions
  pushd ~/.config/coc/extensions
  if [ ! -f package.json ]; then
    echo '{"dependencies":{}}'> package.json
  fi

  # COC plugins
  npm install --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod \
    coc-solargraph \
    coc-tag \
    coc-diagnostic
    popd
}


setup_solargraph() {
  # Solargraph docs
  bundle exec solargraph download-core
  bundle exec yard gems
}

setup_coc
install_coc_extensions
setup_solargraph
