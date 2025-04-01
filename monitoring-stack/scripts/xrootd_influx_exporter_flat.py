####################################################
# XRootD influx exporter                           #
# ------------------------------------------------ #
# With this script, the output from mpxstats -f    #
# is digested and pushed to influxDB.              #
####################################################
import os
import sys
from datetime import datetime

import influxdb_client
from influxdb_client import InfluxDBClient, Point, WritePrecision
from influxdb_client.client.write_api import SYNCHRONOUS

##################################
INFLUXDB_URL = os.getenv('INFLUXDB_URL', 'http://influxdb:8086')
INFLUXDB_ORG = os.getenv('INFLUXDB_ORG', 'MYORG')
INFLUXDB_BUCKET = os.getenv('INFLUXDB_BUCKET', 'XRootD-Monitoring')
INFLUXDB_TOKEN = os.getenv('INFLUXDB_TOKEN', 'my-super-secret-auth-token')
MEASUREMENT = os.getenv('MEASUREMENT', 'not-specified')
TAG_LIST = os.getenv('TAG_LIST', 'no-tags')
DEBUG = os.getenv('DEBUG', '0') == '1'
##################################

client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
write_api = client.write_api(write_options=SYNCHRONOUS)


def convert_unix_to_influx_timestamp(unix_time):
    """
    Converts a Unix timestamp to a timestamp format that InfluxDB understands.
    
    Parameters:
    unix_time (int): The Unix timestamp.
    
    Returns:
    str: The formatted timestamp.
    """
    dt = datetime.utcfromtimestamp(unix_time)
    influx_timestamp = dt.strftime('%Y-%m-%dT%H:%M:%SZ')
    return influx_timestamp


def create_point(log_data, _measurement, tag_list):
    # +-----------+--------+-+---------+-+---------+
    # |measurement|,tag_set| |field_set| |timestamp|
    # +-----------+--------+-+---------+-+---------+

    # Fill the data point for pushing to influxdb
    data_point = Point(_measurement)

    # Set tags
    tags = ''
    tag_values = ''
    for tag in tag_list.split(','):
        tag = tag.strip()  # Remove any surrounding whitespace
        if tag in log_data:
            tags += f'{tag},'
            tag_values += f'{log_data[tag]},'
        else:
            print(f'Tag:{tag} not found. Ignored!')
    data_point.tag(tags, tag_values)

    # Set fields: everything with a '.'
    fields = {key: value for key, value in log_data.items() if '.' in key}
    for field, value in fields.items():
        try:
            data_point.field(field, int(value))
            if DEBUG > 1:  # Verbose
                print("data_point:", data_point)
        except ValueError:
            data_point.field(field, value)  # Store as string if it can't be converted to int

    # Add timestamp
    # data_point.time(convert_unix_to_influx_timestamp(log_data.get("tod")), WritePrecision.NS)
    data_point.time(int(log_data.get("tod")) * 1000000000, WritePrecision.NS)

    if DEBUG > 1:  # Verbose
        print("Created InfluxDB point:", data_point.to_line_protocol())
    exit
    return data_point


def fetch_and_push_to_influx(_measurement, _tag_list):
    if DEBUG:
        print("Starting xrootd log collection from stdin...")

    log_data = {}
    for line in sys.stdin:
        if DEBUG > 2:  # Verbose. very spammy
            print("Read line:", line.strip())

        if line.strip():  # Non-empty line
            key, value = line.strip().split(' ', 1)
            log_data[key] = value
        else:  # Empty line indicates end of log iteration
            if DEBUG > 1:  # Verbose
                print("Complete log data collected:", log_data)
            try:
                point = create_point(log_data, _measurement, _tag_list)
                if DEBUG:
                    print(f"Writing point: {point.to_line_protocol()}", file=sys.stderr)
                write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=point)
                if DEBUG:
                    print("Data written to InfluxDB")
            except Exception as e:
                print("Error writing to InfluxDB:", e)
            log_data = {}  # reset


if __name__ == "__main__":
    fetch_and_push_to_influx(MEASUREMENT, TAG_LIST)

""" DATA
statistics (tod="1716804563" ver="v5.6.9" src="a95c7f8d9331:1094" tos="1716804528" pgm="xrootd" ins="anon" pid="11" site="")
|-- stats (id="info")
|   |-- host: a95c7f8d9331 (the host sending the data)
|   |-- port: 1094 (exposed port of remote server)
|   |-- name: anon
|
|-- stats (id="buff")
|   |-- reqs: 3
|   |-- mem: 132096 (bytes allocated to buffers)
|   |-- buffs: 3
|   |-- adj: 0
|   |-- xlreqs: 0
|   |-- xlmem: 0
|   |-- xlbuffs: 0
|
|-- stats (id="link")
|   |-- num: 0 (current number of connections)
|   |-- maxn: 1 (max number of simultaneous connections)
|   |-- tot: 1 (total connections ?)
|   |-- in: 5194 (bytes received)
|   |-- out: 1556852101 (bytes sent)
|   |-- ctime: 3
|   |-- tmo: 0
|   |-- stall: 0
|   |-- sfps: 0
|
|-- stats (id="poll")
|   |-- att: 0
|   |-- en: 0
|   |-- ev: 1
|   |-- int: 0
|
|-- stats (id="proc") (some node performance things)
|   |-- usr
|   |   |-- s: 0
|   |   |-- u: 725038
|   |-- sys
|       |-- s: 1
|       |-- u: 894713
|
|-- stats (id="xrootd") (TODO)
|   |-- num: 1
|   |-- ops
|   |   |-- open: 1
|   |   |-- rf: 0
|   |   |-- rd: 186
|   |   |-- pr: 0
|   |   |-- rv: 0
|   |   |-- rs: 0
|   |   |-- wv: 0
|   |   |-- ws: 0
|   |   |-- wr: 0
|   |   |-- sync: 0
|   |   |-- getf: 0
|   |   |-- putf: 0
|   |   |-- misc: 2
|   |-- sig
|   |   |-- ok: 0
|   |   |-- bad: 0
|   |   |-- ign: 0
|   |-- aio
|   |   |-- num: 0
|   |   |-- max: 0
|   |   |-- rej: 0
|   |-- err: 0
|   |-- rdr: 0
|   |-- dly: 0
|   |-- lgn
|       |-- num: 1
|       |-- af: 0
|       |-- au: 0
|       |-- ua: 1
|
|-- stats (id="ofs")
|   |-- role: proxy server
|   |-- opr: 0
|   |-- opw: 0
|   |-- opp: 0
|   |-- ups: 0
|   |-- han: 0
|   |-- rdr: 0
|   |-- bxq: 0
|   |-- rep: 0
|   |-- err: 0
|   |-- dly: 0
|   |-- sok: 0
|   |-- ser: 0
|   |-- tpc
|       |-- grnt: 0
|       |-- deny: 0
|       |-- err: 0
|       |-- exp: 0
|
|-- stats (id="pss")
|   |-- open: 0
|   |   |-- errs: 0
|   |-- close: 0
|       |-- errs: 0
|
|-- stats (id="cache" type="pfc")
|   |-- prerd
|   |   |-- in: 0 (bytes read into the cache with pre-read mechanism)
|   |   |-- hits: 0 (cache hits| TODO: pages, files whatever?)
|   |   |-- miss: 0 (analog)
|   |-- rd
|   |   |-- in: 0 (bytes read into the cache)
|   |   |-- out: 0 (bytes read from cache)
|   |   |-- hits: 0 (hits TODO)
|   |   |-- miss: 0 (analog)
|   |-- pass: 0 (bytes read but not cached
|   |   |-- cnt: 0 (Number of times requested data bypassed the cache -> not necessary I guess)
|   |-- wr
|   |   |-- out: 0
|   |   |-- updt: 0
|   |-- saved: 0
|   |-- purge: 0
|   |-- files
|   |   |-- opened: 0 (N of cache files opened)
|   |   |-- closed: 0 (N of cache files closed)
|   |   |-- new: 0 (N of new files)
|   |   |-- del: 0 (N of deleted files)
|   |   |-- now: 0 (N of files? TODO)
|   |   |-- full: 0 
|   |-- store
|   |   |-- size: 189544071168
|   |   |-- used: 0
|   |   |-- min: 0
|   |   |-- max: 0
|   |-- mem
|   |   |-- size: 4294967296
|   |   |-- used: 0
|   |   |-- wq: 0
|   |-- opcl
|       |-- odefer: 1
|       |-- defero: 0
|       |-- cdefer: 0
|       |-- clost: 0
|
|-- stats (id="sched")
|   |-- jobs: 196
|   |-- inq: 0
|   |-- maxinq: 1
|   |-- threads: 5
|   |-- idle: 3
|   |-- tcr: 5
|   |-- tde: 0
|   |-- tlimr: 0
|
|-- stats (id="sgen")
|   |-- as: 0
|   |-- et: 0
|   |-- toe: 1716804563
"""
