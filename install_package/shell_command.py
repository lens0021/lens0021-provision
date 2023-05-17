import subprocess
from typing import List

def exec(command: str|List[str], doPrint: bool = False) -> str:
  if isinstance(command, str):
    command = command.split()
  result = subprocess.run(command, stdout=subprocess.PIPE)
  decoded = result.stdout.decode('utf-8')
  if doPrint:
    print(decoded)
  return decoded

def home() -> str:
  return '/home/nemo'
