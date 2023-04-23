from managed_package import ManagedPackage
import shell_command

class openssh_server(ManagedPackage):

  DNF_NAME = 'openssh-server'

  def post_install():
    shell_command.exec('sudo systemctl enable sshd')
    shell_command.exec('sudo systemctl start sshd')
