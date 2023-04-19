from abc import abstractmethod
from package import Package
from typing import Optional
import shell_command
import re
import os.path

class AppImagePackage(Package):
  DOWNLOAD_URL: Optional[str] = None
  ICON_URL: Optional[str] = None

  def path_to_desktop(self):
    return f'{shell_command.home()}/.local/share/applications/{self.get_name()}.desktop'

  def path_to_app_image(self):
    return f'{shell_command.home()}/.local/bin/{self.get_name()}.AppImage'

  def path_to_icon(self):
    return f'{shell_command.home()}/.icons/{self.get_name()}.png'

  def is_installed(self):
    return os.path.isfile(self.path_to_app_image())

  def real_install(self):
    url = self.get_download_url()
    shell_command.exec(f"curl -L {url} - o '{shell_command.home()}/{self.get_name()}.AppImage")
    shell_command.exec(f"curl -L {self.ICON_URL} - o {self.path_to_icon}")
    shell_command.exec(f'touch {self.path_to_desktop()}')
    shell_command.exec('desktop-file-edit' + ' '.join([
      f'--set-name={self.get_name()}',
      '--set-key=Type --set-value=Application',
      '--set-key=Terminal --set-value=false',
      f'--set-key=Exec --set-value={self.path_to_app_image()}',
      f'--set-key=Icon --set-value=bitwarden',
    ]) + f' {self.path_to_desktop()}')

    shell_command.exec(f'sudo desktop-file-install {self.path_to_desktop()}')

  @abstractmethod
  def get_download_url(self) -> str:
    pass
