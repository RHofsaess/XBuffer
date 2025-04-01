###################################
# THIS VERSION IS NOT RECOMMENDED #
###################################
import json
import os
import sys
import xml.etree.ElementTree as ET

import influxdb_client
from influxdb_client.client.write_api import SYNCHRONOUS

INFLUXDB_URL = os.getenv('INFLUXDB_URL', 'http://influxdb:8086')
INFLUXDB_ORG = os.getenv('INFLUXDB_ORG', 'SCC')
INFLUXDB_BUCKET = os.getenv('INFLUXDB_BUCKET', 'HoreKa')
INFLUXDB_TOKEN = os.getenv('INFLUXDB_TOKEN', 'my-super-secret-auth-token')
DEBUG = os.getenv('DEBUG', '0') == '1'

# Create InfluxDB client
client = influxdb_client.InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
write_api = client.write_api(write_options=SYNCHRONOUS)


def xml_to_json(xml_str):
    """
    Convert an XML string to a JSON dictionary.
    
    Args:
        xml_str (str): The XML string to convert.
        
    Returns:
        dict: The resulting JSON dictionary.
    """

    def parse_element(element):
        """
        Parse an XML element into a dictionary.
        
        Args:
            element (xml.etree.ElementTree.Element): The XML element to parse.
            
        Returns:
            dict: The parsed element as a dictionary.
        """
        parsed_data = {}
        for child in element:
            if len(child):
                # Recursively parse child elements
                parsed_data[child.tag] = parse_element(child)
            else:
                # Add the text content of the element
                parsed_data[child.tag] = child.text
        return parsed_data

    def parse_children(element):
        """
        Parse the children of an XML element, mapping 'id' attributes to their corresponding data.
        
        Args:
            element (xml.etree.ElementTree.Element): The XML element whose children to parse.
            
        Returns:
            dict: The parsed children as a dictionary.
        """
        parsed_data = {}
        for child in element:
            child_data = parse_element(child)  # Parse the child element into a dictionary
            child_attrib = child.attrib.copy()  # Copy the child's attributes
            if 'id' in child_attrib:
                # Use 'id' attribute as the key for the child data
                child_id = child_attrib.pop('id')
                if DEBUG:
                    print(f'Child id: {child_id}')
                parsed_data[child_id] = {**child_data, **child_attrib}
            else:
                # Use the tag name as the key if 'id' is not present
                parsed_data[child.tag] = child_data
        return parsed_data

    # Parse the root element of the XML
    root = ET.fromstring(xml_str)
    json_data = {root.tag: parse_element(root)}  # Convert root element to dictionary
    json_data[root.tag].update(root.attrib)  # Include root attributes in the dictionary

    # Parse <stats> elements and replace 'stats' key with 'id'
    stats_elements = root.findall('stats')
    if stats_elements:
        stats_data = parse_children(root)
        json_data[root.tag].update(stats_data)  # Update with parsed stats data
        del json_data[root.tag]['stats']  # Remove the 'stats' key

    return json_data


def convert_to_point(id, data, metadata):
    """
    Convert JSON data to InfluxDB points.
    
    Args:
        id (str): The ID to use as a tag.
        data (dict): The JSON data to convert.
        metadata (dict): Metadata to include as tags.
        
    Returns:
        list: A list of InfluxDB points.
    """
    points = []
    for key, value in data.items():
        if isinstance(value, dict):
            # Recursively convert nested dictionaries to points
            points.extend(convert_to_point(f"{id}_{key}", value, metadata))
        elif isinstance(value, list):
            # Handle lists of nested dictionaries
            for idx, item in enumerate(value):
                points.extend(convert_to_point(f"{id}_{key}_{idx}", item, metadata))
        else:
            # Treat all values as strings
            value = str(value)
            # Create an InfluxDB point with metadata as tags
            point = influxdb_client.Point("measurement").tag("id", id)
            for meta_key, meta_value in metadata.items():
                point = point.tag(meta_key, meta_value)
            point = point.field(key, value)
            points.append(point)
    return points


def write_to_influx(json_data):
    """
    Write JSON data to InfluxDB.
    
    Args:
        json_data (dict): The JSON data to write.
    """
    points = []
    metadata = {
        'tod': str(json_data['statistics'].get('tod', '')),
        'ver': str(json_data['statistics'].get('ver', '')),
        'src': str(json_data['statistics'].get('src', '')),
        'tos': str(json_data['statistics'].get('tos', '')),
        'pgm': str(json_data['statistics'].get('pgm', '')),
        'ins': str(json_data['statistics'].get('ins', '')),
        'pid': str(json_data['statistics'].get('pid', '')),
        'site': str(json_data['statistics'].get('site', ''))
    }
    for id, data in json_data['statistics'].items():
        # Skip non-stats fields (metadata attributes)
        if id in metadata:
            continue
        points.extend(convert_to_point(id, data, metadata))  # Convert to InfluxDB points

    if DEBUG:
        print(f"Writing points to InfluxDB...")

    # Write the points to InfluxDB
    write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=points)

    if DEBUG:
        print(f"----------End of iteration----------")


if __name__ == "__main__":
    while True:
        try:
            # Read from stdin
            line = sys.stdin.readline().strip()
            if not line:
                continue

            if DEBUG:
                print(f"Received XML: {line}")

            # Parse XML to JSON
            json_data = xml_to_json(line)

            if DEBUG:
                print(f"Converted JSON: {json.dumps(json_data, indent=2)}")

            # Write to InfluxDB
            write_to_influx(json_data)

        except Exception as e:
            print(f"Error: {e}", file=sys.stderr)
            if DEBUG:
                import traceback

                traceback.print_exc()

"""
def fetch_data():
    client = InfluxDBClient(url=INFLUXDB_URL, token=INFLUXDB_TOKEN, org=INFLUXDB_ORG)
    write_api = client.write_api(write_options=WriteOptions(batch_size=1))

    for line in sys.stdin:
        if line.startswith("<statistics"):
            influx_data = parse_xml_data(line.strip())
            print(influx_data)
            if influx_data:
                for point in influx_data:
                    p = Point(point["measurement"])
                    for field, value in point["fields"].items():
                        p = p.field(field, value)
                    if DEBUG:
                        print(f"DEBUG: Writing point: {p.to_line_protocol()}", file=sys.stderr)
                    write_api.write(bucket=INFLUXDB_BUCKET, org=INFLUXDB_ORG, record=p)
"""

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
