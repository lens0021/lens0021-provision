from managed_package import ManagedPackage
import shell_command

class code(ManagedPackage):

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        shell_command.exec('sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc')
        shell_command.exec('sudo sh -c \'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo\'')
        shell_command.exec('dnf check-update')

      case self.DISTRO_DEBIAN_BASE:
        pass
