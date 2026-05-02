#!/usr/bin/env python3
from flask import Flask, send_from_directory
import os

app = Flask(__name__)

# Serve files from this directory
app.static_folder = 'scripts'
app.static_url_base = '/'

@app.route('/')
def index():
    return send_from_directory('scripts', 'refresh_dashboard.html')

@app.route('/dashboard.html')
def dashboard():
    return send_from_directory('scripts', 'refresh_dashboard.html')

@app.errorhandler(404)
def handle_not_found(e):
    return send_from_directory('scripts', 'refresh_dashboard.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=3000)
