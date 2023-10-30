import json

def latest_version(owner: str, repo: str) -> str:
  res = shell_command.exec(f'curl -L https://api.github.com/repos/{owner}/{repo}/releases/latest')
  return json.loads(jsonStr)['tag_name']
