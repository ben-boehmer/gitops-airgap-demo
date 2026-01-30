import os
from flask import Flask

app = Flask(__name__)

@app.get("/")
def hello():
    return "hello\n"

@app.get("/secret")
def secret():
    # DEMO ONLY: secrets niemals offen in Produktion ausgeben
    return f"SECRET_VALUE={os.getenv('SECRET_VALUE', 'MISSING')}\n"
