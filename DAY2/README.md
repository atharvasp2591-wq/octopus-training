# Octopus Day 2 Python Package

This project demonstrates a simple Python package built with modern packaging standards and published through an Azure DevOps pipeline.

## Package overview

The package exposes a simple greeting function that can be used from Python code or from scripts.

## Local development

```bash
python -m pip install --upgrade pip
python -m pip install -U build pytest
python -m pytest -q
python -m build
```

## Usage

```python
from octopus_day2.greeter import welcome

print(welcome("Azure DevOps"))
```
