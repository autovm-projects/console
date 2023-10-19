import argparse
import requests

from help import Help
from dotmap import DotMap

from pyVmomi import vim
from pyVim import connect

parser = argparse.ArgumentParser()

arguments = ['address', 'token']

for argument in arguments:
    parser.add_argument(argument)

args = parser.parse_args()

headers = {
    'token': args.token # AutoVM login token
}

address = Help.append(args.address, '/admin/server/index?type=vc&status=active')

response = requests.get(address, headers=headers).json()

if not response:
    raise Exception('Could not find servers')

servers = response.get('data')

if not servers:
    raise Exception('Could not find servers')

for server in servers:

    server = DotMap(server)

    connection = connect.SmartConnect(host=server.address, user=server.username, pwd=server.password, disableSslCertValidation=True)

    if not connection:
        raise Exception('Could not connect to server')

    content = connection.content

    container = content.viewManager.CreateContainerView(content.rootFolder, [vim.HostSystem], True)

    for item in container.view:

        print(item.name)