from re import search
from importlib import import_module
import re
import os

not_installed = {}
cache = {}
for file in os.listdir('install_package/packages'):
  if not search(re.compile(r'^[A-z][A-z-]+\.py$', flags=re.MULTILINE), file):
    continue

  name = file[0:-3]

  module = import_module(f'packages.{name}')
  PackageClass = getattr(module, name)
  try:
    instance = PackageClass(cache)
  except TypeError:
    print(module)
  not_installed[name] = instance

installed = []
while len(installed) < len(not_installed):
  for name in not_installed:
    deps = not_installed[name].DEPENDENCIES
    if all(p in installed for p in deps):
      not_installed[name].install()
      installed.append(name)

