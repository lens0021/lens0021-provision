from managed_package import ManagedPackage
import shell_command

class Docker(ManagedPackage):
  '''
  https://docs.docker.com/engine/install/fedora/
  '''
  NAME = 'docker-ce'

  def get_package_names(self):
    return [
      'dnf-plugins-core',
      'docker-ce',
      'docker-ce-cli',
      'containerd.io',
    ]

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        self.dnf_add_repo('https://download.docker.com/linux/fedora/docker-ce.repo')
      case self.DISTRO_DEBIAN_BASE:
        raise NotImplementedError

  def post_install(self):
    for cmd in [
      'sudo groupadd docker',
      'sudo usermod -aG docker "$USER"',
      'newgrp docker',
      'sudo systemctl enable docker',
      'sudo systemctl start docker',
      'sudo systemctl enable docker.service',
      'sudo systemctl enable containerd.service',
    ]:
      print('Excuting: ' + cmd)
      shell_command.exec(cmd)
