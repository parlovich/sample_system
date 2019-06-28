#! /usr/bin/python

import json
import logging
from flask import Flask, jsonify, abort, make_response

app = Flask(__name__)

USERS = None


def read_users(filename):
    with open(filename, "r") as f:
        objects = json.load(f)
    return objects["users"]


@app.route('/users', methods=['GET'])
def get_users():
    return jsonify(USERS)


@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    for u in USERS:
        if u["id"] == user_id:
            return jsonify(u)
    abort(404)


@app.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)


if __name__ == "__main__":
    logging.basicConfig(
        format='%(asctime)s %(levelname)-8s %(message)s',
        level=logging.INFO,
        datefmt='%Y-%m-%d %H:%M:%S')

    USERS = read_users("users.json")

    app.run(host="0.0.0.0", port="8081")
