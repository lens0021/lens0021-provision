from package import Package
import shell_command
import os.path

class bats(Package):
  def real_install(self):
    if not os.path.isdir('/usr/local/git/bats-core'):
      shell_command.exec('git clone https://github.com/bats-core/bats-core.git /usr/local/git/bats-core')
    shell_command.exec('sudo /usr/local/git/bats-core/install.sh /usr/local')

  def is_installed(self) -> bool:
    return os.path.exists('/usr/local/bin/bats')
