from managed_package import ManagedPackage
import shell_command

class one_password(ManagedPackage):
  NAME = '1password'
  def real_install(self):
    '''https://developer.1password.com/docs/cli/get-started/#install'''

    print(self.get_name())
    for cmd in [
      'sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc',
      '''sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo''',
    ]:
      shell_command.exec(cmd)
    super().real_install()

  def get_package_names(self):
    return [
      '1password',
      '1password-cli',
    ]
