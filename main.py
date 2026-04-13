import click, os, time
from automate_scripts.write_to_influx import DataPipeline

@click.group()
def cli():
    """CLI tool to manage Automation Script operations."""
    pass

@cli.command()
def influxdb_data_injection():
    """Inject Data to InfluxDB"""
    processor = DataPipeline()
    processor.run()

if __name__ == "__main__":
    cli()