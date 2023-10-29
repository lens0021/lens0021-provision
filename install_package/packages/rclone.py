from managed_package import ManagedPackage
import shell_command

class rclone(ManagedPackage):
  def post_install(self):
    shell_command.exec('mkdir -p "$HOME/dropbox"')

