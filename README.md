![Mac Installer](docs/images/github_banner.png)

Automatically installs all the Apps and configurations you will need for your
journey at instride / Woche-Pass AG.

This script is meant to automate some parts of the onboarding,
so by design this is very opinionated.

## 💾 Download
- Get the files [here](https://github.com/instride-ch/mac-installer/archive/refs/heads/main.zip)
  and extract them, or clone the repository. Any location works.

## ⏱ Preparation
- Sign into the Apple App Store GUI manually
- Make sure you can reach the network share `smb://fs03.wopa.int/recycling` (office network or VPN)

## 💻 Installation
- Open the Terminal app
- Type `bash <path-to-folder>/install.sh`, e.g. `bash ~/Downloads/mac-installer-main/install.sh`
- Hit the [ENTER ↵] key
- Follow the instructions in the terminal. **You will be prompted for your system password**
- At the end the script lists manual steps and opens the folder `ToInstall` with software to install by hand
- Everything is logged to `install.log` in the same folder

Apps that are already installed are detected and skipped, so the script can be run again.

## 👥 Roles

| Role            | Brewfiles                                   | Extras                                   |
|-----------------|---------------------------------------------|------------------------------------------|
| WoPa – Dispo    | `Brewfile`, `Brewfile.wopa_dispo`           | –                                        |
| WoPa – Vorstufe | `Brewfile`, `Brewfile.wopa_vorstufe`        | Adobe / prepress software from the share |
| instride – PL   | `Brewfile`, `Brewfile.instride`, `Brewfile.instride_pl`  | –                           |
| instride – Dev  | `Brewfile`, `Brewfile.instride`, `Brewfile.instride_dev` | nvm + Node LTS                     |
| instride – UX   | `Brewfile`, `Brewfile.instride`, `Brewfile.instride_ux`  | nvm + Node LTS                     |

Role settings live in `roles/`, shared logic in `lib/`.

## 🔄 Update
Run `update.sh` directly (it is not part of the menu):

```bash
bash <path-to-folder>/update.sh
```

It updates Homebrew, all formulae and casks, installs new entries of `~/Brewfile` and updates App Store apps.
