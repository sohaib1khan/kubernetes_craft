from flask import Flask, render_template, request, flash, jsonify
from handlers.file_handler import load_data  # Import load_data
from handlers.log_processor import detect_errors, filter_by_time_range, generate_statistics, generate_visualizations
import pandas as pd
import os
import tempfile
import json
import yaml
import zipfile
from io import BytesIO
import matplotlib.pyplot as plt
import chardet

app = Flask(__name__)
app.secret_key = 'supersecretkey' # ** Need to update this block **

# Function to aggregate multiple log files
def aggregate_logs(files):
    logs = []
    for file in files:
        file_path = os.path.join(tempfile.gettempdir(), file.filename)
        file.save(file_path)
        logs.append(load_data(file_path))
    return pd.concat(logs, ignore_index=True)

# Function to generate output in various formats
def output_result(logs, output_format='table'):
    data_to_display = logs

    if output_format == 'table':
        return data_to_display.to_html(classes="table table-dark table-striped")
    elif output_format == 'json':
        # Pretty-print JSON with indentation
        return f"<pre>{json.dumps(data_to_display.to_dict(orient='records'), indent=4)}</pre>"
    elif output_format == 'yaml':
        # Format YAML output with <pre> tags for better readability
        return f"<pre>{yaml.dump(data_to_display.to_dict(orient='records'), default_flow_style=False)}</pre>"
    elif output_format == 'logs':
        return data_to_display.to_csv(index=False)
    elif output_format == 'raw':
        if 'log' in data_to_display.columns:
            return '<br>'.join(data_to_display['log'].astype(str).values)
        else:
            return "Error: The 'log' column was not found in the uploaded file."
    else:
        raise ValueError("Unsupported output format. Please choose from 'table', 'json', 'yaml', 'logs', or 'raw'.")

# API endpoint for uploading and processing logs
@app.route('/api/upload', methods=['POST'])
def api_upload_file():
    if 'file' not in request.files:
        return jsonify({"error": "No file part. Please upload a valid file."}), 400

    files = request.files.getlist('file')
    if all(f.filename == '' for f in files):
        return jsonify({"error": "No selected file. Please choose files to upload."}), 400

    try:
        # Aggregate and process the logs
        logs = aggregate_logs(files)
        logs = detect_errors(logs)

        output_format = request.form.get('output_format', 'json')  # Default to JSON output

        # If time range filtering is provided, apply it
        if request.form.get('start_time') and request.form.get('end_time'):
            start_time = pd.to_datetime(request.form['start_time'])
            end_time = pd.to_datetime(request.form['end_time'])
            logs = filter_by_time_range(logs, start_time, end_time)

        # Generate stats for the logs
        stats = generate_statistics(logs)

        # Return the processed logs in JSON format for the API
        if output_format == 'json':
            return jsonify(logs.to_dict(orient='records')), 200
        elif output_format == 'yaml':
            return jsonify(yaml.dump(logs.to_dict(orient='records'), default_flow_style=False)), 200
        elif output_format == 'stats':
            return jsonify(stats), 200
        else:
            return jsonify({"error": "Unsupported output format. Please choose 'json', 'yaml', or 'stats'."}), 400

    except UnicodeDecodeError:
        return jsonify({"error": "Unsupported file format or encoding. Please provide a valid log file."}), 400
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

# Existing manual upload route (HTML)
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        flash("No file part. Please upload a valid file.", 'danger')
        return render_template('index.html')

    files = request.files.getlist('file')
    if all(f.filename == '' for f in files):
        flash("No selected file. Please choose files to upload.", 'danger')
        return render_template('index.html')

    try:
        # Aggregate and process the logs
        logs = aggregate_logs(files)
        logs = detect_errors(logs)

        output_format = request.form.get('output_format')

        # If time range filtering is provided, apply it
        if request.form.get('start_time') and request.form.get('end_time'):
            start_time = pd.to_datetime(request.form['start_time'])
            end_time = pd.to_datetime(request.form['end_time'])
            logs = filter_by_time_range(logs, start_time, end_time)

        # Generate stats and visualizations
        stats = generate_statistics(logs)
        viz_image = generate_visualizations(logs)

        # Generate the output with the chosen format
        output = output_result(logs, output_format)
        return render_template('result.html', output=output, stats=stats, image=viz_image)

    except UnicodeDecodeError:
        flash("Error: Unsupported file format or encoding. Please provide a valid log file.", 'danger')
        return render_template('index.html')
    except ValueError as e:
        flash(f"Error: {e}", 'danger')
        return render_template('index.html')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5009, threaded=False)
