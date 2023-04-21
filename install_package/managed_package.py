from package import Package
from typing import Optional
import shell_command
import re

class ManagedPackage(Package):
  DNF_NAME: Optional[str] = None
  APT_NAME: Optional[str] = None

  DISTRO_FEDORA = 'fedora'
  DISTRO_DEBIAN_BASE = ['ubuntu', 'debian']
  DISTRO_UBUNTU = 'ubuntu'
  DISTRO_DEBIAN = 'debian'

  def get_name(self) -> str:
    if self.DNF_NAME:
      return self.DNF_NAME
    elif self.APT_NAME:
      return self.APT_NAME

    return super().get_name()

  def is_installed(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        return self.is_rpm_installed()
      case self.DISTRO_DEBIAN_BASE:
        pass

    return False

  def real_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        pkgs = ' '.join(self.get_package_names())
        shell_command.exec(f'sudo dnf -y install {pkgs}')
      case self.DISTRO_DEBIAN_BASE:
        pkgs = ' '.join(self.get_package_names())
        shell_command.exec(f'sudo apt install -y {pkgs}')

  def get_package_names(self):
    return [self.get_name()];

  def dnf_add_repo(self, url: str):
    shell_command.exec(f'sudo dnf config-manager --add-repo {url}')
