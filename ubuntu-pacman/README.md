## Pacman on Ubuntu

### Keyringについて

```bash
sudo apt install archlinux-keyring
sudo mkdir -p /usr/share/pacman/keyrings
sudo ln -s /usr/share/keyrings/archlinux.gpg /usr/share/pacman/keyrings/
sudo ln -s /usr/share/keyrings/archlinux-revoked /usr/share/pacman/keyrings/
sudo ln -s /usr/share/keyrings/archlinux-trusted /usr/share/pacman/keyrings/
sudo pacman-key --populate
```

