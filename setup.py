from setuptools import setup

setup(
    name='arista-ceoslab',
    version='1.0',
    scripts=['topo-ceos'],
    install_requires=[
        'argparse',
        'logging',
        'PyYAML',
        'docker'
    ],
    package_data={'': ['*.yml']},
    url='https://github.com/networkop/arista-ceos-topo',
    license='BSD3',
    author='Michael Kashin',
    author_email='mkashin@aristsa.com',
    description='Arista cEOS topology builder'
)
