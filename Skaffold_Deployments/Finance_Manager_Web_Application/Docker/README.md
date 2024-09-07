# Finance Manager Web Application

This is a simple web application built with Flask that allows users to manage their finances. The app supports adding, editing, and removing monthly goals and expenses and displays the data in a user-friendly interface with scrollable tables.

## Project Structure

```
.
├── app.py                       # Main Flask application
├── data/
│   └── finance_data.json        # JSON file to store financial data
├── run_docker.sh                # Bash script to build and run the app in Docker
├── run_flask.sh                 # Bash script to run the app locally with Flask
├── static/
│   └── style.css                # CSS styling for the application
└── templates/
    ├── edit_expense.html        # Template for editing expense entries
    ├── edit_month.html          # Template for editing monthly goals
    └── index.html               # Main template for viewing and managing data

```

## Features

- Add, edit, and delete monthly goals and results.
- Add, edit, and delete expense entries.
- Scrollable tables to handle large amounts of data.
- Simple and clean UI with a moving northern lights background effect.
- Docker support for easy deployment.

## Requirements

- Python 3.7+
- Flask
- Docker (if running in a container)

## Setup Instructions

### Running Locally

1.  **Clone the repository:**

```
git clone https://github.com/sohaib1khan/Finance_Manager_Web_Application.git
cd finance-manager

```

&nbsp; 2. **Install required Python packages:**

Run the following command to install Flask:

```
pip install flask
```

&nbsp;3. **Run the Flask application:**

You can run the Flask application directly using the provided bash script:

```
./run_flask.sh
```

This will start the Flask application locally on `http://127.0.0.1:5005`.

### Running with Docker

1.  **Build and run the Docker container:**
    
    Use the provided bash script to build the Docker image and run the container:
    

```
./run_docker.sh
```

This will build the Docker image, start the container, and the app will be accessible at `http://<your-ip-address>:5005`.

&nbsp; 2. **Accessing the Application:**

The script will output the IP address and port where you can access the web interface. Typically, this would be:

```
http://<your-ip-address>:5005
```

Default username and password can be in changed in the following  `data/user.json`  file. 

```
    "username": "admin",
    "password": "password123"

```


### Managing Data

- **Adding Data:** You can add monthly goals, results, and expenses using the forms provided in the web interface.
- **Editing Data:** Use the "Edit" buttons next to each entry to modify existing data.
- **Deleting Data:** Use the "Delete" buttons next to each entry to remove data.

### Customizing the Application

- **CSS Styling:** The application's styles are defined in `static/style.css`. You can modify this file to change the appearance of the application.
- **Templates:** The HTML templates are stored in the `templates/` directory. You can modify these templates to change the layout or add new features.

