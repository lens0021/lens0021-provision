from re import search
from importlib import import_module
import re
import os

cache = {}

def check_requirements(deps, installed):
  for dep in deps:
    if dep not in installed:
      # print(f'dependency {dep} is not installed')
      return False
  return True

def install_packages():
  not_installed = {}
  for file in os.listdir('install_package/packages'):
    if not search(re.compile(r'^[A-z][A-z-]*\.py$', flags=re.MULTILINE), file):
      continue

    name = file[0:-3]

    module = import_module(f'packages.{name}')
    PackageClass = getattr(module, name)
    try:
      instance = PackageClass(cache)
      not_installed[name] = instance
    except TypeError as e:
      print(str(e), module)

  installed = []
  while len(installed) < len(not_installed):
    for name in not_installed:
      if name not in installed:
        deps = not_installed[name].DEPENDENCIES
        if check_requirements(deps, installed):
          not_installed[name].install()
          installed.append(name)

def install_commands():
  for file in os.listdir('install_package/commands'):
    if not search(re.compile(r'^[A-z][A-z-]+\.py$', flags=re.MULTILINE), file):
      continue

    name = file[0:-3]

    module = import_module(f'commands.{name}')
    PackageClass = getattr(module, name)
    try:
      instance = PackageClass(cache)
      instance.install()
    except TypeError:
      print(module)

if __name__ == '__main__':
  install_packages()
  install_commands()

