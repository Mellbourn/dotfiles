# dotfiles

My personal configuration files and scripts.

I use [yadm](https://github.com/TheLocehiliosan/yadm) to manage my dotfiles.

## Installation

### MacOS

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install yadm git-crypt
yadm clone https://github.com/Mellbourn/dotfiles.git
yadm crypt unlock <keyfile>
yadm bootstrap
.config/yadm/bootstrap-sudo
```

### Windows Subsystem for Linux

```PowerShell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
```

Install Ubuntu from the Windows store, then continue the instructions under the heading "Ubuntu"

### Ubuntu & Debian

```bash
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y git yadm
ssh-keygen -t ed25519 -C "klas@mellbourn.net"
<add ssh key to github>
yadm clone https://github.com/Mellbourn/dotfiles.git
yadm crypt unlock <keyfile>
yadm submodules update
yadm bootstrap
~/.config/yadm/bootstrap-sudo
```

## post Installation

After SSH keys have been set up, enable pushing changes by pasting the public key into GitHub and changing the remote URL.

```bash
pbcopy < ~/.ssh/id_rsa.pub
# paste the key manually to github account, then change the remote url
yadm remote set-url origin git@github.com:Mellbourn/dotfiles.git
```
