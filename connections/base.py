from abc import ABC, abstractmethod

class Connection(ABC):
    @abstractmethod
    def connect(self):
        pass

    @abstractmethod
    def get_database(self):
        pass

    @abstractmethod
    def close(self):
        pass