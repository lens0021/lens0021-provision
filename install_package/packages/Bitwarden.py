from app_image_package import AppImagePackage
import github

class Bitwarden(AppImagePackage):
  DEPENDENCIES = [
    'curl',
  ]

  ICON_URL = 'https://github.com/bitwarden/brand/raw/master/icons/512x512.png'

  def get_download_url(self) -> str:
    ver = github.latest_version(owner='bitwarden', repo='clients')
    DOWNLOAD_URL = 'https://github.com/bitwarden/clients/releases/download/desktop-v$1/Bitwarden-$1-x86_64.AppImage'
    return DOWNLOAD_URL.replace('$1', ver)
