from package import Package
import shell_command

class FlatpakPackage(Package):

  def is_installed(self):
    return shell_command.exec('flatpak list --app | grep com.authy.Authy; echo $?') == '0'

  def real_install(self):
    shell_command.exec('flatpak install -y ' + self.get_name())
