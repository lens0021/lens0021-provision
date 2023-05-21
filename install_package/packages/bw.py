from package import Package
import shell_command
import json
import os.path

class bw(Package):
  # DISABLED = True
  DEPENDENCIES = [
    'gh',
    'jq',
    'unzip',
  ]

  def latest(self):
    jsonStr = shell_command.exec(f"gh api repos/bitwarden/Clients/releases")
    rels = json.loads(jsonStr)
    latestCliVersion = None
    latestCliId = 0
    for rel in rels:
      if latestCliId < rel['id'] and rel['tag_name'].startswith('cli-'):
        latestCliVersion = rel['tag_name']
    return latestCliVersion[5:]

  def real_install(self):
    ver = self.latest()
    url = f'https://github.com/bitwarden/clients/releases/download/cli-v{ver}/bw-linux-{ver}.zip'
    dl = shell_command.home() + '/Downloads'
    shell_command.exec(f'curl -L {url} -o {dl}/bw.zip')
    shell_command.exec(f'unzip {dl}/bw.zip -d {dl}')
    shell_command.exec(f'sudo install {dl}/bw /usr/local/bin/bw')
    shell_command.exec(f'rm {dl}/bw.zip {dl}/bw')

  def is_installed(self) -> bool:
    return os.path.exists('/usr/local/bin/bw')
