#!/bin/python3
import os
import sys
import json
import logging
from logging.handlers import RotatingFileHandler

from opensearchpy import OpenSearch

host = os.getenv('os_host')  #'localhost'
port = os.getenv('os_port')  # 9200
auth = (os.getenv('user'), os.getenv('password')) 
index_name = os.getenv('index')

# ########## LOGGING ##########
# Create a custom logger
logger = logging.getLogger(__name__)

# Set the global logging level
logger.setLevel(logging.DEBUG)  # This can be adjusted to INFO, WARNING, etc.

# Create handlers
console_handler = logging.StreamHandler()
file_handler = RotatingFileHandler(
    'opensearch_exporter.log',
    maxBytes=5*1024*1024,  # 5 MB
    backupCount=5
)

# Set level for handlers
console_handler.setLevel(logging.INFO)
file_handler.setLevel(logging.DEBUG)

# Create formatters and add them to the handlers
console_format = logging.Formatter('%(name)s - %(levelname)s - %(message)s')
file_format = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s (%(filename)s:%(lineno)d)')

#console_handler.setFormatter(console_format)
#file_handler.setFormatter(file_format)
console_handler.setFormatter(formatter)
file_handler.setFormatter(formatter)

# Add handlers to the logger
logger.addHandler(console_handler)
logger.addHandler(file_handler)

# ########## CONNECTION ##########
try:
    client = OpenSearch(
        hosts=[{'host': host, 'port': port}],
        http_auth=auth,
        use_ssl=True,
        verify_certs=False,
        ssl_show_warn=False
    )
    logger.info('Connected to OpenSearch cluster')
except Exception as e:
    logger.error(f'Error connecting to OpenSearch: {e}')
    exit(1)


# ########## GET DATA ##########
input_data = sys.stdin.read()
print(input_data)
try:
    data = json.loads(input_data)
except json.JSONDecodeError as e:
    logger.error(f'Failed to parse JSON data: {e}')
    exit(1)

# ########## PUSHING ##########
# Indexing the data
try:
    response = client.index(
        index=index_name,
        body=data,
        refresh=True
    )
    logger.info(f'Document indexed.')
    logger.debug(f'Indexing response: {response}')
except Exception as e:
    logger.error(f'An error occurred while indexing the document: {e}')




"""
# Index settings and mappings
# Can be used to create an index with specific characteristics
index_body = {
    'settings': {
        'number_of_shards': 1,
        'number_of_replicas': 0
    },
    'mappings': {
        'properties': {
            'title': {'type': 'text'},
            'content': {'type': 'text'},
            'timestamp': {'type': 'date'}
        }
    }
}

# Create the index
try:
    response = client.indices.create(index=index_name, body=index_body, ignore=400)
    if 'acknowledged' in response and response['acknowledged']:
        logger.info(f'Index "{index_name}" created successfully.')
    elif 'error' in response:
        logger.error(f'Error creating index "{index_name}": {response["error"]["reason"]}')
    else:
        logger.info(f'Index "{index_name}" already exists.')
except Exception as e:
    logger.error(f'An exception occurred while creating the index: {e}')
"""

"""
# Validation of input
from jsonschema import validate, ValidationError

schema = {
    "type": "object",
    "properties": {
        "title": {"type": "string"},
        "content": {"type": "string"},
        "timestamp": {"type": "string", "format": "date-time"}
    },
    "required": ["title", "content", "timestamp"]
}

try:
    validate(instance=doc, schema=schema)
except ValidationError as e:
    logger.error(f'JSON validation error: {e}')
    continue  # Skip invalid documents
"""
