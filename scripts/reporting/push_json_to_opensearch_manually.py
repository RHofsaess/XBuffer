from opensearchpy import OpenSearch
import datetime

host = '<HOSTNAME>'  # e.g., 'localhost' or 'opensearch.example.com'
port = <PORT>  # Default port is 9200
auth = ('<USER>', '<PASSWORD>')  # Replace with your credentials if needed
index_name = 'my-index'
now=datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')

client = OpenSearch(
    hosts = [{'host': host, 'port': port}],
    http_auth = auth,  # Remove this line if authentication is not required
    use_ssl = True,    # Set to False if SSL is not used
    verify_certs = False,
    ssl_show_warn = False
)

data = {
    'title': 'Sample Document',
    'content': 'This is a sample document to be indexed in OpenSearch.',
    'timestamp': f'{now}'
}


response = client.index(
    index = index_name,
    body = data,
    refresh = True  # Makes the document searchable immediately
)

print(response)
