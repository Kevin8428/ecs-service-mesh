import requests
ip = '10.0.29.129'
port = '4000'
url = "http://{}:{}/message".format(ip, port)
print("publishing to url: ", url)
message_body = {'message': 'hellllooo'}
response = requests.get(url, params={'message': message_body}, timeout=10)
print('response: ', response)