from managed_package import ManagedPackage
import shell_command

class helix(ManagedPackage):
  # https://docs.helix-editor.com/install.html#fedorarhel

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        shell_command.exec('sudo dnf copr enable -y varlad/helix')
      case self.DISTRO_DEBIAN_BASE:
        raise NotImplementedError

  def post_install(self):
    for cmd in [
      'hx -g fetch',
      'hx -g build',
    ]:
      shell_command.exec(cmd)

