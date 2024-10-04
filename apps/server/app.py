"""
Server used to write messages RDS.
"""
import os
import json
import logging

from flask import Flask, request, Response
import pymysql
import boto3

logging.basicConfig(level=os.environ.get("LOG_LEVEL", "INFO"))
logger = logging.getLogger(__name__)
app = Flask(__name__)

SM_CLIENT = boto3.client('secretsmanager', region_name='us-west-2')

def get_db_configs():
    """
    Fetch configs from Secrets Manager
    """
    secret_name = SM_CLIENT.get_secret_value(SecretId=os.environ.get('SECRET_ARN'))
    secret_dict = json.loads(secret_name['SecretString'])
    return secret_dict['username'], secret_dict['password']


@app.route("/status")
def status():
    """
    Router to validate service health
    """
    return Response("{'status':'healthy'}", status=200, mimetype='application/json')


@app.route("/message", methods=['GET'])
def save_message():
    """
    Router to store message in DB
    """
    print('hit /message handler')
    message = request.args.get('language')
    print('message found: ', message)
    # username, password = get_db_configs()
    # print('username: ', username)
    # print('password: ', password)

    # connection = pymysql.connect(
    #     host=os.environ.get('HOST_DNS'),
    #     port=os.environ.get('PORT', 3306),
    #     user=username,
    #     password=password,
    #     database=os.environ.get('DATABASE_NAME')
    # )
    # logging.info('connection: %s', connection)
    return {'status': 'success'}, 200

if __name__ == "__main__":
    print('running 1.1')
    port = int(os.environ.get('PORT', 5000))
    app.run(debug=True, host='0.0.0.0', port=port)
