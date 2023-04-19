from managed_package import ManagedPackage
import shell_command

class howdy(ManagedPackage):
  """
  TODO: https://support.system76.com/articles/setup-face-recognition/
  """

  DISABLED = True

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        shell_command('sudo dnf copr enable -y principis/howdy')
      case self.DISTRO_DEBIAN_BASE:
        raise NotImplementedError
