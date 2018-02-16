# dotfiles

My personal configuration files and scripts.

I use [yadm](https://github.com/TheLocehiliosan/yadm) to manage my dotfiles.

## Installation

### MacOS

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&
brew install yadm &&
yadm clone --bootstrap git@github.com:Mellbourn/dotfiles.git &&
sudo .yadm/bootstrap-sudo &&
yadm decrypt
```

### Windows Subsystem for Linux / Ubuntu

```PowerShell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

Install Ubuntu from windows store

```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install yadm
yadm clone git@github.com:Mellbourn/dotfiles.git
sudo ~/.yadm/bootstrap-sudo
~/.yadm/bootstrap
````
