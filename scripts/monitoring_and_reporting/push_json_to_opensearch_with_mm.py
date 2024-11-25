#!/bin/python3
import os
import sys
import json
import requests
import logging
from logging.handlers import RotatingFileHandler

from opensearchpy import OpenSearch

##################################
OS_HOST = os.getenv('OS_HOST')  #'localhost'
OS_PORT = os.getenv('OS_PORT')  # 9200
OS_AUTH = (os.getenv('OS_USER'), os.getenv('OS_PASSWORD')) 
OS_INDEX = os.getenv('OS_INDEX')
##################################
MM_URL = os.getenv('MM_URL')  # +++++ ATTENTION +++++: only works with python > 3.6.8
MM_ACCESS_TOKEN = os.getenv('MM_ACCESS_TOKEN')
MM_TEAM_ID = os.getenv('MM_TEAM_ID')  # can be found with: the api -- see README
MM_CHANNEL_ID = os.getenv('MM_CHANNEL_ID')  # analog
MM_CHANNEL = os.getenv('MM_CHANNEL')  # only for logging
##################################

# ########## Mattermost ##########
def send_message(logger: logging.Logger, message: str) -> None:
    '''
    Function to send messages as a mattermost bot to a dedicated channel if an alert message is handed over.
    
    Note: In older python versions (tested with 3.6.8), requests cannot handle f-strings and a hard-coding is required!

    Parameter:
    ----------
    logger: logging.Logger
    message: string

    Return:
    -------
    None
    '''
    if len(message) < 1:  # only send if alert is triggert
        return

    headers = {
            'Authorization': f'Bearer {ACCESS_TOKEN}',
            'Content-Type': 'application/json'
    }
    data = {
            'channel_id': MM_CHANNEL_ID,
            'team_id' : MM_TEAM_ID,
            'message': message
    }
    logger.debug(f'[MMBot] Data: {data}')

    try:
        response = requests.post(
                #f'{MM_URL}/api/v4/posts',  # +++++ ATTENTION +++++: only works with python > 3.6.8
                'https://your.mattermost.url/api/v4/posts',
                headers=headers,
                json=data
        )
        logger.debug(f'Full response: {response.text}')
        if response.status_code != 201:
            logger.error(f'Failed to send message: {response.text}')
        else:
            logger.info(f'Message send to {CHANNEL}')

    except Exception as e:
        logger.error(f'Sending failed with error: {e}')

def prepare_report(data: json) -> str:
    '''
    This function is used to prepare the input json and create alerts that should be sent to mattermost.
    It is creating a report message based on selected alert criteria and returns a message string.

    Parameters:
    -----------
    data: json

    Return:
    --------
    message: str
    '''
    message = ''

    if not data:
        return ''
    else:  # check and create alert message
        if (data["instance_running"] == 1):
            message += 'Instance not running!\n'
        if (data["instance_running"] == 2):
            message += 'Instance was restarted!\n'
        if (data["voms_remaining_s"] < 36000 ):
            message += f'Voms proxy is running out in {data["voms_remaining_s"]}s\n'
        if len(message) > 1:
            return '+++++ Alert +++++\n' + message
        else:
            return message  # empty string

# ########## LOGGING ##########
# Create a custom logger
logger = logging.getLogger(__name__)

# Set the global logging level
logger.setLevel(logging.INFO)  # This can be adjusted to INFO, WARNING, etc.

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
        hosts=[{'host': OS_HOST, 'port': OS_PORT}],
        http_auth=OS_AUTH,
        use_ssl=True,
        verify_certs=False,
        ssl_show_warn=False
    )
    logger.info('Connected to OpenSearch cluster.')
except Exception as e:
    logger.error(f'Error connecting to OpenSearch: {e}')
    exit(1)


# ########## GET DATA ##########
input_data = sys.stdin.read()
try:
    data = json.loads(input_data)
    logger.debug(f'Recieved input data: {data}')
    send_message(logger, prepare_report(data))  # send MM message
except json.JSONDecodeError as e:
    logger.error(f'Failed to parse JSON data: {e}')
    exit(1)

# ########## PUSHING ##########
# Indexing the data
try:
    response = client.index(
        index=OS_INDEX,
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
