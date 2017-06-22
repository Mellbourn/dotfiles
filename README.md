# dotfiles

My personal configuration files and scripts.

I use [yadm](https://github.com/TheLocehiliosan/yadm) to manage my dotfiles.

## Installation

### Preparations

```bash
# add key to github https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/:
ssh-keygen -t rsa -b 4096 -C "klas@mellbourn.net"
# manually modify your ~/.ssh/config to contain this
# Host *
#  AddKeysToAgent yes
#  UseKeychain yes
#  IdentityFile ~/.ssh/id_rsa
# store key in apple keychain
ssh-add -K ~/.ssh/id_rsa
# add the key manually to github account
pbcopy < ~/.ssh/id_rsa.pub
```

### Main installation

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&
brew install yadm &&
yadm clone --bootstrap git@github.com:Mellbourn/dotfiles.git &&
sudo .yadm/bootstrap-sudo &&
yadm decrypt
```
