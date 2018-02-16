from setuptools import setup

setup(
    name='arista-ceoslab',
    version='1.0',
    scripts=['ceos-topo'],
    install_requires=[
        'pyyaml',
        'docker'
    ],
    data_files=[('examples', ['2-node.yml','3-node-yml'])],
    url='https://github.com/networkop/arista-ceos-topo',
    license='BSD3',
    author='Michael Kashin',
    author_email='mkashin@aristsa.com',
    description='Arista cEOS topology builder'
)
