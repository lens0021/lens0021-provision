import subprocess

def exec(command: str, doPrint: bool = False) -> str:
  result = subprocess.run(command.split(), stdout=subprocess.PIPE)
  decoded = result.stdout.decode('utf-8')
  if doPrint:
    print(decoded)
  return decoded

def home() -> str:
  return '/home/nemo'
