# dotfiles

My personal configuration files and scripts.

I use [yadm](https://github.com/TheLocehiliosan/yadm) to manage my dotfiles.

## Installation

### MacOS

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&
brew install yadm &&
yadm clone --bootstrap https://github.com/Mellbourn/dotfiles.git &&
.config/yadm/bootstrap-sudo &&
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
ssh-keygen -t ed25519 -C "klas@mellbourn.net"
<add ssh key to github>
yadm clone --recurse-submodules https://github.com/Mellbourn/dotfiles.git
yadm bootstrap
~/.config/yadm/bootstrap-sudo
yadm decrypt
```

## post Installation

After ssh keys have been set up, enable pushing changes by pasting the public key into github and changing the remote url.

```bash
pbcopy < ~/.ssh/id_rsa.pub
# paste the key manually to github account, then change the remote url
yadm remote set-url origin git@github.com:Mellbourn/dotfiles.git
```
