import setuptools
import os.path as osp

version = {}
with open(osp.join(osp.dirname(__file__), "rnvs_tb/version.py")) as fp:
    exec(fp.read(), version)

setuptools.setup(
    name='rnvs-tb',
    version = version['__version__'],
    author='Sebastian Bräuer',
    author_email='braeuer@tkn.tu-berlin.de',
    description='TU Berlin RNVS course testbenches',
    packages=setuptools.find_packages(),
    install_requires=[
        'docker>=3.0.0'
    ],
    include_package_data=True,
    package_data={'rnvs_tb': ['Dockerfile_buildenv']},
    entry_points={
        'console_scripts': [
            'rnvs-tb-dht = rnvs_tb.blocks.block6:main',
        ]
    }
)
