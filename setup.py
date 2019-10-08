from setuptools import setup
import os
import sys

EXTRA_FILES = "topo-extra-files"


def collect_files():
    return [
        (d, [os.path.join(d, f) for f in files])
        for d, folders, files in os.walk(EXTRA_FILES)
    ]


setup(
    name="docker-topo",
    version="2.0.3",
    scripts=["bin/docker-topo"],
    data_files=collect_files(),
    python_requires=">=3.5",
    install_requires=["pyyaml", "docker", "netaddr", "packaging"] + (["pyroute2==0.5.3"] if 'linux' in sys.platform.lower() else []),
    url="https://github.com/networkop/docker-topo",
    license="BSD3",
    author="Michael Kashin",
    author_email="mmkashin@gmail.com",
    description="Docker network topology builder",
)
