from managed_package import ManagedPackage
import shell_command

class GoogleChrome(ManagedPackage):
  DNF_NAME = 'google-chrome-stable'

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        shell_command.exec('sudo dnf config-manager --set-enabled google-chrome')
      case self.DISTRO_DEBIAN_BASE:
        pass
