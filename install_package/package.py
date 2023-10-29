from installation import Installation
import shell_command
import re

class Package(Installation):
  DISTRO_FEDORA = 'fedora'
  DISTRO_DEBIAN_BASE = ['ubuntu', 'debian']
  DISTRO_UBUNTU = 'ubuntu'
  DISTRO_DEBIAN = 'debian'

  def which_distro(self) -> str:
    if 'os-release' not in self.cache:
      infos = shell_command.exec('cat /etc/os-release', False)
      match = re.search(re.compile(r'^ID=(.+)$', flags=re.MULTILINE), infos)

      if not match:
        raise Exception(f"no match\n ${infos}")
      self.cache['os-release'] =  match.group(1)

    return self.cache['os-release']

  def is_rpm_installed(self) -> bool:
    if 'rpm -qa' not in self.cache:
      self.cache['rpm -qa'] = shell_command.exec('rpm -qa', False)
    match = re.search(re.compile(f'^{self.get_name()}-', flags=re.MULTILINE), self.cache['rpm -qa'])
    if match:
      return True
    return False
