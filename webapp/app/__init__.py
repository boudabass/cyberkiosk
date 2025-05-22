from flask import Flask
from .routes_admin import admin_bp

def create_app():
    app = Flask(__name__)
    app.secret_key = 'change_this_secret_key'
    app.register_blueprint(admin_bp)
    # ... autres blueprints et config
    return app
