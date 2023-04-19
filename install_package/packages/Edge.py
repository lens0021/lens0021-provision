from managed_package import ManagedPackage
import shell_command

class Edge(ManagedPackage):
  DNF_NAME = 'microsoft-edge-stable'
  DISABLED = True

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        shell_command('sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc')
        shell_command('sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge')

      case self.DISTRO_DEBIAN_BASE:
        pass
