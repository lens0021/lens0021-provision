from package import Package
import shell_command

class FlatpakPackage(Package):

  def is_installed(self):
    return shell_command.exec(f'flatpak list --app | grep ${self.NAME}; echo $?') == '0'

  def real_install(self):
    shell_command.exec('flatpak install -y ' + self.get_name())
