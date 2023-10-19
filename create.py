import argparse
import requests

from help import Help

parser = argparse.ArgumentParser()

arguments = ['address', 'token', 'host', 'proxy']

for argument in arguments:
    parser.add_argument(argument)

args = parser.parse_args()

headers = {
    'token': args.token # AutoVM login token
}

address = Help.append(args.address, '/admin/proxy/save')

params = {
    'host': args.host, 'proxy': args.proxy, 'port': 443
}

response = requests.post(address, params=params, headers=headers).json()

if not response:
    raise Exception('Could not create proxy')

proxy = response.get('data')

if not proxy:
    raise Exception('Could not create proxy')

print(proxy)