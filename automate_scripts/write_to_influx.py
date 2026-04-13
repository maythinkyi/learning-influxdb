
import os, logging
from connections.connection_manager import ConnectionManager
from datetime import datetime, timezone
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.DEBUG, 
                    format='%(asctime)s - %(levelname)s - %(message)s')

conn_manager = ConnectionManager()
conn_manager.add_connection("influx", uri=os.getenv("INFLUX_URI"),
                             token=os.getenv("INFLUX_TOKEN"),
                               org=os.getenv("INFLUX_ORG"),
                                )
influx_db = conn_manager.get_connection("influx").get_database()

class DataPipeline:
    def __init__(self):
        self.data = [
            {"time": "2026-04-13T10:00:00Z", "location": "coyote_creek", "degrees": 75},
            {"time": "2026-04-13T10:00:00Z", "location": "santa_monica", "degrees": 65},

            {"time": "2026-04-13T10:12:00Z", "location": "coyote_creek", "degrees": 82},
            {"time": "2026-04-13T10:12:00Z", "location": "santa_monica", "degrees": 85},

            {"time": "2026-04-13T10:24:00Z", "location": "coyote_creek", "degrees": 88},
            {"time": "2026-04-13T10:24:00Z", "location": "santa_monica", "degrees": 90},
        ]

    def push_metrics_to_influx(self, data:list):
        try:
            if not data:
                return
            
            for item in data:
                
                point = {
                    "measurement": os.getenv("INFLUX_MEASUREMENT"),
                    "tags": {
                        "location": item.get("location")
                    },
                    "fields": {
                        "degrees": item.get("degrees")
                    },
                    "time": item.get("time")
                }
                influx_db["write_api"].write(bucket=os.getenv("INFLUX_BUCKET") ,record=point)
            logging.info(f"Successfully write metrics to Influx DB...")
        except Exception as e:
            logging.error(f"Error writing to InfluxDB: {e}")

    def clear_measurement(self):
        
        measurement = os.getenv("INFLUX_MEASUREMENT")
        influx_db["delete_api"].delete( 
            start=datetime(datetime.now().year, 1, 1, tzinfo=timezone.utc),
            stop=datetime.now(timezone.utc),
            predicate = f'_measurement="{measurement}"',
            bucket=os.getenv("INFLUX_BUCKET"),
            org=os.getenv("INFLUX_ORG")
        )

    def run(self):
        self.clear_measurement()
        self.push_metrics_to_influx(self.data)

