from managed_package import ManagedPackage
import shell_command

class docker_compose(ManagedPackage):
  DEPENDENCIES = ['docker']

  def get_package_names(self):
    return [
      'docker-compose-plugin',
      # https://phabricator.wikimedia.org/T283484
      'docker-compose'
    ]

  def pre_install(self):
    match self.which_distro():
      case self.DISTRO_FEDORA:
        self.dnf_add_repo('https://download.docker.com/linux/fedora/docker-ce.repo')
      case self.DISTRO_DEBIAN_BASE:
        raise NotImplementedError
