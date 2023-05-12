from package import Package
import shell_command
import os.path
import github

class saml2aws(Package):
  def real_install(self):
    ver = github.latest_version('Versent', 'saml2aws').lstrip('v')
    url = f'https://github.com/Versent/saml2aws/releases/download/v{ver}/saml2aws_{ver}_linux_amd64.tar.gz'
    dl = shell_command.home() + '/Downloads'
    for cmd in [
      f'curl -L {url} -o {dl}/saml2aws.tar.gz',
      f'tar -xzvf {dl}/saml2aws.tar.gz -C {dl}',
      f'sudo install {dl}/saml2aws /usr/local/bin/saml2aws',
      f'rm {dl}/README.md {dl}/LICENSE.md',
    ]:
      shell_command.exec(cmd)

  def is_installed(self) -> bool:
    return os.path.exists('/usr/local/bin/saml2aws')
