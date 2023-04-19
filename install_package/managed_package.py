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

  def which_distro(self):
    if 'os-release' not in self.cache:
      infos = shell_command.exec('cat /etc/os-release', False)
      match = re.search(re.compile(r'^ID=(.+)$', flags=re.MULTILINE), infos)

      if not match:
        raise Exception(f"no match\n ${infos}")
      self.cache['os-release'] =  match.group(1)

    return self.cache['os-release']

  def get_name(self) -> str:
    if self.DNF_NAME:
      return self.DNF_NAME
    elif self.APT_NAME:
      return self.APT_NAME

    return super().get_name()

  def is_installed(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        if 'rpm -qa' not in self.cache:
          self.cache['rpm -qa'] = shell_command.exec('rpm -qa', False)
        match = re.search(re.compile(f'^{self.get_name()}', flags=re.MULTILINE), self.cache['rpm -qa'])
        if match:
          return True
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
