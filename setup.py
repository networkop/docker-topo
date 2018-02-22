from setuptools import setup
import os

EXTRA_FILES='arista-ceos-files'

def collect_files():
    return [(d, [os.path.join(d,f) for f in files])
            for d, folders, files in os.walk(EXTRA_FILES)]

setup(
    name='arista-ceoslab',
    version='1.0',
    scripts=['bin/ceos-topo'],
    data_files=collect_files(),
    install_requires=[
        'pyyaml',
        'docker'
    ],
    url='https://github.com/networkop/arista-ceos-topo',
    license='BSD3',
    author='Michael Kashin',
    author_email='mkashin@aristsa.com',
    description='Arista cEOS topology builder'
)
