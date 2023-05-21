from managed_package import ManagedPackage
import shell_command

class Vivaldi(ManagedPackage):
  DNF_NAME = 'vivaldi-stable'
  DISABLED = True

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        shell_command.exec('sudo dnf config-manager --add-repo https://repo.vivaldi.com/archive/vivaldi-fedora.repo')

      case self.DISTRO_DEBIAN_BASE:
        pass
