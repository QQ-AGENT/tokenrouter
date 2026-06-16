#!/usr/bin/env python3
"""TokenRouter — Open-source version (MIT licensed)"""
from setuptools import setup, find_packages
setup(
    name="tokenrouter",
    version="0.1.0",
    description="Drop-in LLM cost optimization middleware (50-80% savings)",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="QQ Army",
    license="MIT",
    packages=find_packages(),
    python_requires=">=3.9",
    install_requires=["urllib3>=1.26"],
    entry_points={
        "console_scripts": [
            "tokenrouter=tokenrouter.server:main",
        ],
    },
)
