from managed_package import ManagedPackage
import shell_command

class DockerDesktop(ManagedPackage):
  DISABLED = True

  def real_install(self):
    # DOCKER_DESKTOP_URL=$(curl -sL https://docs.docker.com/desktop/install/linux-install/ | grep -oE 'https://desktop\.docker\.com/linux/main/amd64/docker-desktop-.+-x86_64\.rpm')
    # sudo dnf install -y "$DOCKER_DESKTOP_URL"
    pass
