#!/usr/bin/env lua

print('██╗  ██╗ ██╗██╗     ██████╗  ██████╗  ██████╗ ')
print('██║ ██╔╝███║██║     ██╔════╝ ██╔═══██╗██╔══██╗')
print('█████╔╝ ╚██║██║     ██║███╗  ██║   ██║██████╔╝')
print('██╔═██╗  ██║██║     ██║   ██║██║   ██║██╔══██╗')
print('██║  ██╗ ██║███████╗╚██████╔╝╚██████╔╝██║  ██║')
print('╚═╝  ╚═╝ ╚═╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝')

local color = {
  RESET = "\27[0m",
  RED = "\27[31m",
  GREEN = "\27[32m",
  YELLOW = "\27[33m",
  BLUE = "\27[34m",
  MAGENTA = "\27[35m",
  CYAN = "\27[36m",
}

function print_color(message, color_code)
  print(color_code .. message .. color.RESET)
end

if not os.getenv("SUDO_UID") then
  print_color("\n** ERROR => Run me with sudo\n", color.RED)
  os.exit(1)
end

local os_release = io.open('/etc/os-release'):read('*all')

local distro_patterns = {
  arch = "arch",
  debian = "debian|ubuntu|kali",
  suse = "suse",
  gentoo = "gentoo",
  slackware = "slackware",
  fedora = "fedora",
  rhel = "rhel",
  alpine = "alpine",
  void = "void"
}

function get_distro()
  for distro, pattern in pairs(distro_patterns) do
    if os_release:find(pattern) then
      return distro
    end
  end
  return ''
end

local function common_update_steps()
  -- Common update steps for all distributions
  os.execute('echo 3 >/proc/sys/vm/drop_caches')
end

local update = {
  arch = function()
    os.execute(
      'pacman -Syyu --noconfirm && \
      yay -Syyu --noconfirm && \
      pacman -Scc --noconfirm && \
      rm -rf /tmp/* && \
      rm -rf /var/tmp/* && \
      pacman -Rns $(pacman -Qtdq) --noconfirm && \
      paccache -r')
    common_update_steps()
  end,
  debian = function()
    os.execute(
      'apt update && \
      apt dist-upgrade -y && \
      apt autoclean && \
      apt autoremove -y'
    )
    if not io.open('/usr/bin/aptitude') then
      os.execute('apt install -y aptitude')
    end
    os.execute('aptitude purge ~c -y')
    common_update_steps()
  end,
  suse = function()
    os.execute(
      'zypper refresh && \
      zypper update -y && \
      zypper cc -a && \
      zypper packages --orphaned | awk \'{print $4}\' | xargs zypper remove -y')
    common_update_steps()
  end,
  rhel = function()
    os.execute(
      'yum check-update -y && \
      yum update -y && \
      yum clean all && \
      package-cleanup --leaves --all && \
      package-cleanup --orphans && \
      yum autoremove -y')
    common_update_steps()
  end,
  fedora = function()
    os.execute(
      'dnf upgrade -y && \
      dnf clean all && \
      dnf autoremove -y && \
      dnf remove $(dnf repoquery --extras --unneeded --quiet) -y')
    common_update_steps()
  end,
  slackware = function()
    os.execute(
      'slackpkg update && \
      slackpkg upgrade-all && \
      slackpkg upgrade slackpkg && \
      slackpkg upgrade aaa_glibc-solibs && \
      slackpkg new-config && \
      slackpkg clean-system')
  end,
  gentoo = function()
    os.execute(
      'emaint -a sync && \
      emerge -avuDN --with-bdeps=y @world && \
      emerge -av --depclean && \
      emerge --ask --depclean && \
      emerge --ask --depclean --exclude world && \
      emerge --ask --depclean --exclude world')
    common_update_steps()
  end,
  alpine = function()
    os.execute(
      'apk update && \
      apk upgrade -y && \
      apk cache clean && \
      apk autoremove -y && \
      apk fix --no-cache')
  end,
  void = function()
    os.execute(
      'xbps-install -Su && \
      xbps-install -S && \
      xbps-remove -o && \
      xbps-remove -R old && \
      xbps-remove -C && \
      fstrim -av')
  end
}

function clear_swap()
  local handle = io.popen("blkid | grep swap 2>&1")
  local result = handle:read("*a")
  handle:close()

  if string.find(result, "swap") then
    os.execute("swapoff -a && swapon -a")
  end
end

print_color('\n** INFO => Start updating your distro...\n', color.YELLOW)
local distro = get_distro()
if distro ~= '' then
  update[distro]()
  clear_swap()
  print_color('\n** INFO => Update has finished!!\n', color.GREEN)
else
  print('\n** ERROR => Unsupported distribution\n', color.RED)
end
