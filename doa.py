from sqlalchemy import Column, REAL, INTEGER, TIMESTAMP
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine
from sqlalchemy.sql import func

Base = declarative_base()

class Temperature (Base) :
    __tablename__ = 'temperature'

    id = Column(INTEGER, primary_key=True, autoincrement=True )
    chipid = Column(INTEGER)
    temp1 = Column(REAL)
    humi1 = Column(REAL)
    timestamp = Column(TIMESTAMP, default=func.now())

engine = create_engine('sqlite:///temperatures.db')
Base.metadata.create_all(engine)
