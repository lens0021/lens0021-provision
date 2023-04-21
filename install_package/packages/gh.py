from package import Package
import shell_command
import github

class gh(Package):

  def real_install(self):
    ver = github.latest_version(['cli', 'cli'])
    match self.which_distro():
      case self.DISTRO_FEDORA:
        url = f"https://github.com/cli/cli/releases/download/v{ver}/gh_{ver}_linux_amd64.rpm"
        shell_command.exec(f'sudo dnf install -y {url}')
      case self.DISTRO_DEBIAN_BASE:
        # TODO
        # curl -L "https://github.com/cli/cli/releases/download/v${GITHUB_CLI_VERSION}/gh_${GITHUB_CLI_VERSION}_linux_amd64.deb" \
        #   -o ~/Downloads/gh_linux_amd64.deb
        # sudo dpkg -i ~/Downloads/gh_linux_amd64.deb
        # rm ~/Downloads/gh_linux_amd64.deb
        pass

  def is_installed(self) -> bool:
    match self.which_distro():
      case self.DISTRO_FEDORA:
        return self.is_rpm_installed()
      case self.DISTRO_DEBIAN_BASE:
        raise NotImplementedError
