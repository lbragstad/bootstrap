# bootstrap

An Ansible playbook and the configuration it manages, for bringing up new
workstations. Targets Fedora and macOS; the roles branch on `os_family`.

## Usage

The playbook runs against the machine you are sitting at. Install Ansible
first — `sudo dnf install ansible` on Fedora, `brew install ansible` on macOS —
then:

```
ansible-playbook site.yml -K
```

`-K` prompts for the sudo password, which is needed to install packages and to
change the login shell. Everything is idempotent, so re-running is cheap — and
once the login shell is zsh, `--tags configure` needs no sudo at all.

| Command | What it does |
| --- | --- |
| `ansible-playbook site.yml -K` | Full bootstrap: install tools, then apply preferences |
| `ansible-playbook site.yml --tags configure` | Preferences only — symlinks, gitconfig, plugins, GNOME settings |
| `ansible-playbook site.yml --tags install -K` | Install and link tools, skip GNOME settings |
| `ansible-playbook site.yml --tags update -K` | Upgrade packages, neovim, and tmux/nvim plugins in place |
| `ansible-playbook site.yml --tags neovim` | Just one role — also `packages`, `shell`, `dotfiles`, `tmux`, `fonts`, `gnome` |

Add `--check --diff` to preview.

## Layout

```
site.yml          the play; wires up the roles and their tags
group_vars/all.yml  identity, package-independent settings, the file lists
roles/packages    dnf + flatpak on Fedora, Homebrew formulae + casks on macOS
roles/shell       zsh as the login shell, oh-my-zsh, git completion, gvm
roles/dotfiles    symlinks configs/ into $HOME, renders ~/.gitconfig
roles/neovim      neovim itself, the config symlink, packer and mason
roles/tmux        tpm and the tmux plugins
roles/fonts       Hack Nerd Font (Fedora; macOS gets it as a cask)
roles/gnome       workspace keybindings and the dock (Fedora)
configs/          the actual configuration files, symlinked into place
bin/              helper scripts, symlinked into ~/.local/bin
nvim/             neovim configuration, symlinked to ~/.config/nvim
```

Configs are symlinked rather than copied, so editing a file in `configs/` takes
effect without re-running the playbook. `~/.gitconfig` is the exception: it
carries absolute paths, so it is rendered from
`roles/dotfiles/templates/gitconfig.j2` and a re-run is needed after an edit.

## Personalising

`group_vars/all.yml` holds the git identity, the signing key path, the list of
configs to link, and the list of `bin/` scripts to expose. The package lists
live in `roles/packages/vars/main.yml`.

Anything that is true of one machine rather than all of them — account ids,
work-specific endpoints, api credentials — goes in `~/.zshrc.local`, which
`configs/zshrc` sources last if it exists. That file is created by hand and is
never tracked here, so it is also the right place for values that should stay
out of git history.
