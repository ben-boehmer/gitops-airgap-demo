from flask import Flask
import os

app = Flask(__name__)

@app.get("/")
def hello():
    env = os.getenv("ENVIRONMENT", "dev")
    return {"service": "hello-service", "env": env, "status": "ok"}
