from managed_package import ManagedPackage
import shell_command

class Wavebox(ManagedPackage):
  NAME = 'Wavebox'

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        for cmd in [
          'sudo rpm --import https://download.wavebox.app/static/wavebox_repo.key',
          'sudo wget -P /etc/yum.repos.d/ https://download.wavebox.app/stable/linux/rpm/wavebox.repo',
        ]:
          shell_command.exec(cmd)

      case self.DISTRO_DEBIAN_BASE:
        pass

# TODO: Set as default browser
