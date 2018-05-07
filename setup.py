from setuptools import setup
import os

EXTRA_FILES='topo-extra-files'

def collect_files():
    return [(d, [os.path.join(d,f) for f in files])
            for d, folders, files in os.walk(EXTRA_FILES)]

setup(
    name='docker-topo',
    version='2.0',
    scripts=['bin/docker-topo'],
    data_files=collect_files(),
    install_requires=[
        'pyyaml',
        'docker',
        'netaddr'
        'pyroute2'
    ],
    url='https://github.com/networkop/arista-ceos-topo',
    license='BSD3',
    author='Michael Kashin',
    author_email='mkashin@arista.com',
    description='Docker network topology builder'
)
