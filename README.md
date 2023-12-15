# Lua Distro Updater

`distro_updater.lua` is a utility script to automate package updates on various Linux distributions. It supports updating package lists, upgrading installed packages, cleaning package caches, and performing system maintenance tasks.

## Table of Contents

- [Lua Distro Updater](#lua-distro-updater)
  - [Table of Contents](#table-of-contents)
  - [Information](#information)
    - [Key Features](#key-features)
  - [Prerequisites](#prerequisites)
  - [Usage](#usage)
  - [Supported Distros-based](#supported-distros-based)
  - [License](#license)
  - [Contributing](#contributing)

## Information

`distro_updater.lua` simplifies the package update process on different Linux distributions. It provides a unified to perform updates, making it convenient for users across various environments.

### Key Features

- Automatic package list update
- Upgrade installed packages
- Clean package caches
- System maintenance tasks

## Prerequisites

To use `distro_updater.lua`, ensure that you have the following prerequisites installed on your system:

- Linux OS
- Bash/Z shell or what ever shell you prefer
- [Lua](https://www.lua.org/download.html)

## Usage

To update your distribution, run the following commands:

```bash
curl https://raw.githubusercontent.com/k1lgor/lua_distro_update/main/distro_updater.lua \
-o ~/distro_updater.lua && \
chmod +x ~/distro_updater.lua && \
sudo ~/distro_updater.lua
```

## Supported Distros-based

`distro_updater.lua` supports the following Linux distributions:

- **Alpine**
- **Arch**
- **Debian**
- **Fedora**
- **Gentoo**
- **Kali**
- **openSUSE**
- **RHEL**
- **Slackware**
- **Ubuntu**
- **Void**

## License

This project is licensed under the [MIT License](LICENSE.md) - see the [LICENSE.md](LICENSE.md) file for details.

## Contributing

I welcome contributions to `distro_updater.lua`. To contribute, follow these steps:

1. Fork the repository.
2. Create a new branch.
3. Make your changes.
4. Submit a pull request.

For more details, please refer to [CONTRIBUTING.md](CONTRIBUTING.md).

Feel free to customize the content based on your project's specific details. Ensure that you replace placeholder information with accurate details related to your project.
