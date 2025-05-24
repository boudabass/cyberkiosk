import os
from flask import Flask
from dotenv import load_dotenv  # <-- Ajoute cette ligne
from .routes_admin import admin_bp
from .routes_main import main_bp

load_dotenv()  # <-- Charge les variables du .env

def create_app():
    app = Flask(__name__)
    app.secret_key = os.environ.get('SECRET_KEY', 'dev_key_insecure')
    app.register_blueprint(admin_bp)
    app.register_blueprint(main_bp)
    return app

