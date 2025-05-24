from flask import Blueprint, render_template
from .whitelist import get_whitelist

main_bp = Blueprint('main', __name__)

@main_bp.route('/')
def index():
    whitelist = get_whitelist()  # Récupère la liste des domaines autorisés
    return render_template('index.html', whitelist=whitelist)

