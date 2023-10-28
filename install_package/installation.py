from abc import ABC, abstractmethod
from typing import Optional

class Installation(ABC):
  NAME: Optional[str] = None
  DEPENDENCIES = []
  DISABLED = False

  def __init__(self, cache):
    self.cache = cache

  def install(self):
    if self.DISABLED:
      pass
    elif self.is_installed():
      print(f'Skip install {self.get_name()}')
    else:
      print(f'🚀 install {self.get_name()}')
      self.pre_install()
      self.real_install()
      self.post_install()

  @abstractmethod
  def is_installed(self) -> bool:
    pass

  def pre_install(self):
    pass

  @abstractmethod
  def real_install(self):
    pass

  def post_install(self):
    pass

  def get_name(self) -> str:
    if self.NAME:
      return self.NAME
    return self.__class__.__name__
