# handlers/log_processor.py

import pandas as pd
import matplotlib.pyplot as plt
from io import BytesIO

def detect_errors(logs):
    """Detects errors in the logs based on keywords."""
    error_keywords = ['error', 'fail', 'exception', 'critical']
    logs['is_error'] = logs.apply(lambda row: any(keyword in str(row).lower() for keyword in error_keywords), axis=1)
    return logs

def filter_by_time_range(logs, start_time, end_time):
    """Filters logs based on the provided time range."""
    logs['time'] = pd.to_datetime(logs['log'], errors='coerce')  # Assuming logs have timestamps
    return logs[(logs['time'] >= start_time) & (logs['time'] <= end_time)]

def generate_statistics(logs):
    """Generates statistics about the logs (total logs, error logs, etc.)."""
    total_logs = len(logs)
    error_logs = len(logs[logs['is_error']])
    stats = {
        'total_logs': total_logs,
        'error_logs': error_logs,
        'error_percentage': (error_logs / total_logs) * 100 if total_logs > 0 else 0
    }
    return stats

def generate_visualizations(logs):
    """Generates a simple visualization of errors vs non-errors in the logs."""
    error_count = logs['is_error'].sum()
    non_error_count = len(logs) - error_count

    fig, ax = plt.subplots()
    ax.bar(['Errors', 'Non-Errors'], [error_count, non_error_count])
    plt.title('Error vs Non-Error Logs')
    plt.ylabel('Count')

    output = BytesIO()
    plt.savefig(output, format='png')
    plt.close(fig)
    output.seek(0)

    return output
