# handlers/file_handler.py
import os
import pandas as pd
import yaml
import chardet

def load_data(file_path):
    """Detects file type based on extension and loads data accordingly."""
    file_extension = os.path.splitext(file_path)[1]
    
    if file_extension == '.csv':
        return pd.read_csv(file_path)
    elif file_extension in ['.xls', '.xlsx']:
        return pd.read_excel(file_path)
    elif file_extension == '.json':
        return pd.read_json(file_path)
    elif file_extension in ['.yaml', '.yml']:
        with open(file_path, 'r') as file:
            return pd.DataFrame(yaml.safe_load(file))
    else:
        with open(file_path, 'rb') as file:
            result = chardet.detect(file.read())
        encoding = result['encoding'] if result['confidence'] > 0.5 else 'utf-8'
        with open(file_path, 'r', encoding=encoding, errors='ignore') as file:
            lines = file.readlines()
            return pd.DataFrame(lines, columns=['log'])
