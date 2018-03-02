from flask import Flask
from flask import request
from flask import jsonify
import sqlite3

from doa import Temperature, engine
from sqlalchemy.orm import sessionmaker

Session = sessionmaker(bind=engine)

app = Flask(__name__)

@app.route('/test')
def test():
    print "Testing!"
    return 'OK'

@app.route('/senddata', methods=['GET'])
def process_new_data():
    id = request.args.get('id', None)
    temp1 = request.args.get('temp1', None)
    humi1 = request.args.get('humi1', None)

    session = Session()

    newRow = Temperature(chipid=id, temp1=temp1, humi1=humi1)
    session.add(newRow)
    session.commit()

    return 'OK'

@app.route('/dumpall')
def dump_all():
    session = Session()

    temps = session.query(Temperature).all()

    def temp_to_json(temp):
        return { 'id' : temp.id,
                 'chipid' : temp.chipid,
                 'temp1' : temp.temp1,
                 'humi1' : temp.humi1,
                 'timestamp' : temp.timestamp
               }

    data = map(temp_to_json, temps)
    return jsonify(data)

if __name__ == '__main__':
    print "Hello!"
    app.run(host='0.0.0.0', port=8881)


