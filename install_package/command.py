from installation import Installation
import shell_command
import re
from typing import Optional

class Command(Installation):
  DEPENDENCIES = []
  DISABLED = False
  SCRIPT: Optional[str] = None

  def __init__(self, cache):
    self.cache = cache

  def is_installed(self):
    rc = shell_command.exec(f'cat {shell_command.home()}/.bashrc')
    return bool(re.search(self.get_name(), rc))

  def real_install(self):
    with open(f'{shell_command.home()}/.bashrc', 'a') as f:
      f.write(self.SCRIPT)
