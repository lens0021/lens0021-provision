from managed_package import ManagedPackage
import shell_command

class rclone(ManagedPackage):
  post_install:
    shell_command.exec('mkdir -p "$HOME/dropbox"')

