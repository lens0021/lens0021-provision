from managed_package import ManagedPackage
import shell_command
import os.path

class winehq(ManagedPackage):
  NAME = 'winehq-staging'
  DISABLED = True

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        if not os.path.isdir('/etc/yum.repos.d/winehq.repo'):
          VERSION_ID=shell_command.exec('rpm -E %fedora')
          shell_command.exec(f'sudo dnf config-manager --add-repo "https://dl.winehq.org/wine-builds/fedora/{VERSION_ID}/winehq.repo"')
      case self.DISTRO_DEBIAN:
        # sudo wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
        # CODE_NAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d= -f2)
        # sudo wget -nc -P /etc/apt/sources.list.d/ "https://dl.winehq.org/wine-builds/debian/dists/${CODE_NAME}/winehq-${CODE_NAME}.sources"
        pass
      case self.DISTRO_UBUNTU:
        # https://wiki.winehq.org/Ubuntu
        # sudo dpkg --add-architecture i386
        # wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -
        # CODE_NAME=$(cat /etc/os-release | grep UBUNTU_CODENAME | cut -d= -f2)
        # sudo add-apt-repository "deb https://dl.winehq.org/wine-builds/ubuntu/ ${CODE_NAME} main"
        pass
