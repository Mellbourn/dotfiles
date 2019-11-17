# dotfiles

My personal configuration files and scripts.

I use [yadm](https://github.com/TheLocehiliosan/yadm) to manage my dotfiles.

## Installation

### MacOS

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&
brew install yadm &&
yadm clone --bootstrap git@github.com:Mellbourn/dotfiles.git &&
sudo .config/yadm/bootstrap-sudo &&
yadm decrypt
```

### Windows Subsystem for Linux

```PowerShell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

Install Ubuntu from windows store, then continue the instructions under the heading "Ubuntu"

### Ubuntu & Debian

```bash
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y git yadm
yadm clone https://github.com/Mellbourn/dotfiles.git
~/.config/yadm/bootstrap
~/.config/yadm/bootstrap-sudo
yadm decrypt
```
