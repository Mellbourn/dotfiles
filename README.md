# dotfiles

My personal configuration files and scripts.

I use [yadm](https://github.com/TheLocehiliosan/yadm) to manage my dotfiles.

## Installation

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &&
brew install yadm

# add key to github https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
ssh-keygen -t rsa -b 4096 -C "klas@mellbourn.net"
# modify your ~/.ssh/config
ssh-add -K ~/.ssh/id_rsa
# add the key manually to github account

yadm clone --bootstrap git@github.com:Mellbourn/dotfiles.git &&
sudo .yadm/bootstrap-sudo &&
yadm decrypt
```
