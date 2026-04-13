from connections.influx import InfluxConnection

class ConnectionManager:
    def __init__(self):
        self.databases = {}
    
    def add_connection(self, db_type, **kwargs):
        if db_type == "influx":
            conn = InfluxConnection(kwargs.get("uri"), kwargs.get("token"), kwargs.get("org"))
        else:
            raise ValueError("Unsupported DB type")
        conn.connect()
        self.databases[db_type] = conn

    def get_connection(self, name):
        return self.databases.get(name)
    
    def close(self,name=None):
        if not name:
            self.databases.get(name).close()
        else:
            for conn in self.databases.values():
                conn.close()



