#!/bin/bash

set -e

# Basic tools
sudo apt update 
sudo apt install -y git curl zsh tmux build-essential xclip xse wl-clipboard xxd
sudo snap update
sudo snap install -y nvim

# Neovim Plugin setup
echo "[*] Setting up Neovim config..."
mkdir -p ~/.config
ln -sf $(pwd)/.config/nvim ~/.config/nvim

echo "[*] Bootstrapping lazy.nvim plugin manager..."
git clone https://github.com/folke/lazy.nvim.git ~/.local/share/nvim/site/pack/lazy/start/lazy.nvim

echo "[*] Syncing Neovim plugins..."
nvim --headless "+Lazy sync" +qa
