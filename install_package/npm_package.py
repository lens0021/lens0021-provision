from package import Package
from typing import Optional
import shell_command
import re

class NpmPackage(Package):
  DEPENDENCIES = [
    # 'npm'
  ]

  def is_installed(self):
    return False
    if 'npm' not in self.cache:
      # TODO
      self.cache['npm'] = shell_command.exec('npm', False)
    match = re.search(re.compile(f'^{self.get_name()}', flags=re.MULTILINE), self.cache['npm'])
    if match:
      return True

    return False

  def real_install(self):
    # TODO
    pass
