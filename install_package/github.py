import requests

def latest_version(owner: str, repo: str) -> str:
  json = requests.get(f'https://api.github.com/repos/{owner}/{repo}/releases/latest')
  return json['tag_name']
