#!/usr/bin/env python

from flask import Flask, request
import requests

import logging
import sys
logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

app = Flask(__name__)


@app.route("/")
def home():
    return "Hello, World!"


@app.route('/hello')
def hello():
    url = "http://web:8001/hello"
    r = requests.get(url, headers=request.headers)

    if r.status_code != 200:
        return "Access to the Web service is forbidden.\n", r.status_code
    return r.content, r.status_code


@app.route('/the/good/path')
def the_good_path():
    url = "http://web:8001/the/good/path"
    r = requests.get(url, headers=request.headers)

    if r.status_code != 200:
        return "Access to the Web service is forbidden.\n", r.status_code
    return r.content, r.status_code


@app.route('/the/bad/path')
def the_bad_path():
    url = "http://web:8001/the/bad/path"
    r = requests.get(url, headers=request.headers)
    return r.content, r.status_code


if __name__ == "__main__":
    app.run(debug=True)
