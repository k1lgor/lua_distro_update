#!/usr/bin/env lua

print('██╗  ██╗ ██╗██╗     ██████╗  ██████╗  ██████╗ ')
print('██║ ██╔╝███║██║     ██╔════╝ ██╔═══██╗██╔══██╗')
print('█████╔╝ ╚██║██║     ██║███╗  ██║   ██║██████╔╝')
print('██╔═██╗  ██║██║     ██║   ██║██║   ██║██╔══██╗')
print('██║  ██╗ ██║███████╗╚██████╔╝╚██████╔╝██║  ██║')
print('╚═╝  ╚═╝ ╚═╝╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝')

if os.getenv("SUDO_UID") == nil then
  print("\n** ERROR => Run me with sudo\n")
  os.exit(1)
end

function get_distro()
  local DISTRO = ''

  if io.open('/etc/os-release'):read('*all'):find('arch') then
    DISTRO = 'arch'
  elseif io.open('/etc/os-release'):read('*all'):find('debian') or
  io.open('/etc/os-release'):read('*all'):find('ubuntu') or
  io.open('/etc/os-release'):read('*all'):find('kali') then
    DISTRO = 'debian'
  elseif io.open('/etc/os-release'):read('*all'):find('suse') then
    DISTRO = 'suse'
  elseif io.open('/etc/os-release'):read('*all'):find('gentoo') then
    DISTRO = 'gentoo'
  elseif io.open('/etc/os-release'):read('*all'):find('slackware') then
    DISTRO = 'slackware'
  elseif io.open('/etc/os-release'):read('*all'):find('fedora') then
    DISTRO = 'fedora'
  elseif io.open('/etc/os-release'):read('*all'):find('rhel') then
    DISTRO = 'rhel'
  elseif io.open('/etc/os-release'):read('*all'):find('alpine') then
    DISTRO = 'alpine'
  elseif io.open('/etc/os-release'):read('*all'):find('void') then
    DISTRO = 'void'
  end
  return DISTRO
end

local update = {
  ["arch"] = function()
    os.execute('pacman -Syyu --noconfirm && \
                yay -Syyu --noconfirm && \
                pacman -Scc --noconfirm && \
                rm -rf /tmp/* && \
                rm -rf /var/tmp/* && \
                pacman -Rns $(pacman -Qtdq) --noconfirm && \
                echo 3 >/proc/sys/vm/drop_caches')
  end,
  ["debian"] = function()
    --[[
      1. Update the package lists
      2. Upgrade all installed packages to their latest version
      3. Clean the local repository of retrieved package files that can no longer be downloaded
      4. Remove packages that are no longer needed
      5. Remove all orphaned packages
      6. Clear memory cache of Linux system
    ]]
    os.execute('apt update && \
                apt dist-upgrade -y && \
                apt autoclean && \
                apt autoremove -y')
    if not io.open('/usr/bin/aptitude') then
      os.execute('sudo apt install -y aptitude')
    end
    os.execute('aptitude purge ~c -y && \
                echo 3 >/proc/sys/vm/drop_caches')
  end,
  ["suse"] = function()
    --[[
      1. Update the package repositories
      2. Upgrade all installed packages to the latest version
      3. Clean up the package cache
      4. Remove orphaned packages
      5. Clear memory cache of Linux system
    ]]
    os.execute('zypper refresh && \
                zypper update -y && \
                zypper cc -a && \
                zypper packages --orphaned | awk '{print $4}' | xargs zypper remove -y && \
                echo 3 >/proc/sys/vm/drop_caches')
  end,
  ["rhel"] = function()
    --[[
      1. Update the package repositories
      2. Upgrade all packages to their latest versions
      3. Clean the local repository cache to free up disk space
      4-5. Remove orphaned packages that are no longer needed
      6. Clean up the system by removing unnecessary packages and dependencies
      7. Clear memory cache of Linux system
    ]]
    os.execute('yum check-update -y && \
                yum update -y && \
                yum clean all && \
                package-cleanup --leaves --all && \
                package-cleanup --orphans && \
                yum autoremove -y && \
                echo 3 >/proc/sys/vm/drop_caches')
  end,
  ["fedore"] = function()
    --[[
      1. Update the package lists and upgrade all installed packages
      2. Clean the package cache and remove old package versions
      3. Remove packages that are no longer required
      4. Remove orphaned packages
      5. Clear memory cache of Linux system
    ]]
    os.execute('dnf upgrade -y && \
                dnf clean all && \
                dnf autoremove -y && \
                dnf remove $(dnf repoquery --extras --unneeded --quiet) -y && \
                echo 3 >/proc/sys/vm/drop_caches')
  end,
  ["slackware"] = function()
    --[[
      1. Update the package database
      2. Upgrade all installed packages
      3. Upgrade the Slackware package manager
      4. Upgrade the glibc-solibs package
      5. Create a new configuration file
      6. Remove any packages that are no longer needed
    ]]
    os.execute('slackpkg update && \
                slackpkg upgrade-all && \
                slackpkg upgrade slackpkg && \
                slackpkg upgrade aaa_glibc-solibs && \
                slackpkg new-config && \
                slackpkg clean-system')
  end,
  ["gentoo"] = function()
    --[[
      1. Update the portage tree
      2. Update the system
      3. Clean up unneeded packages
      4. Clean up packages that are not part of the world set
      5. Remove any orphaned packages
      6. Clean up the distfiles
    ]]
    os.execute('emaint -a sync && \
                emerge -avuDN --with-bdeps=y @world && \
                emerge -av --depclean && \
                emerge --ask --depclean && \
                emerge --ask --depclean --exclude world && \
                emerge --ask --depclean --exclude world')
  end,
  ["alpine"] = function()
    --[[
      1. Update the package index
      2. Upgrade installed packages
      3. Remove cached packages
      4. Remove orphaned packages
      5. Remove unused dependencies
    ]]
    os.execute('apk update && \
                apk upgrade -y && \
                apk cache clean && \
                apk autoremove -y && \
                apk fix --no-cache')
  end,
  ["void"] = function()
    --[[
      1. Update packages
      2. Sync package database
      3. Remove orphaned packages
      4. Remove old package versions
      5. Clean package cache
      6. Trim unused disk blocks
    ]]
    os.execute('xbps-install -Su && \
                xbps-install -S && \
                xbps-remove -o && \
                xbps-remove -R old && \
                xbps-remove -C && \
                fstrim -av')
  end
}

function clear_swap()
  local handle = io.popen("sudo blkid | grep swap 2>&1")
	local result = handle:read("*a")
	handle:close()

	if string.find(result, "swap") then
		os.execute("swapoff -a && swapon -a")
	end
end

print('\n** Start updating your distro...\n')
get_distro()
update[get_distro()]()
clear_swap()
print('\n** Update has finished!!\n')
