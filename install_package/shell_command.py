import subprocess
from typing import List

def exec(command: str|List[str], doPrint: bool = False) -> str:
  if not isinstance(command, str):
    command = ' '.join(str)
  result = subprocess.getoutput(command)
  if doPrint:
    print(result)
  return result

def home() -> str:
  return '/home/nemo'
