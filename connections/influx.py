from connections.base import Connection
from influxdb_client import InfluxDBClient
from influxdb_client.client.write_api import SYNCHRONOUS


class InfluxConnection(Connection):
    def __init__(self, uri=None, token=None, org=None, bucket=None):
        self.uri = uri
        self.token = token
        self.org = org
        self.bucket = bucket
        self.client = None

    def connect(self):
        self.client = InfluxDBClient(
            url=self.uri,
            token=self.token,
            org=self.org,
            timeout=60000 # 60 seconds
        )
        return self.client
    
    def get_database(self):
        return {
            "delete_api": self.client.delete_api(),
            "write_api": self.client.write_api(write_options=SYNCHRONOUS),
            "query_api": self.client.query_api(),
            "bucket": self.bucket,
            "org": self.org,
        }
    
    def close(self):
        if self.client:
            self.client.close()
        