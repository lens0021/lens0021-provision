import requests

def latest_version(owner: str, repo: str) -> str:
  res = requests.get(f'https://api.github.com/repos/{owner}/{repo}/releases/latest')
  return res.json()['tag_name']
