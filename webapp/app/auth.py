import os
from functools import wraps
from flask import Blueprint, render_template, request, redirect, url_for, session, flash

# Variables d'environnement pour l'admin
ADMIN_USER = os.environ.get('ADMIN_USER', 'admin')
ADMIN_PASSWORD = os.environ.get('ADMIN_PASSWORD', 'admin')

auth_bp = Blueprint('auth', __name__, url_prefix='/admin')

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if not session.get('admin_logged_in'):
            flash("Authentification requise.")
            return redirect(url_for('auth.login', next=request.path))
        return f(*args, **kwargs)
    return decorated_function

def check_credentials(username, password):
    return username == ADMIN_USER and password == ADMIN_PASSWORD

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        if check_credentials(username, password):
            session['admin_logged_in'] = True
            flash("Connexion réussie.")
            next_page = request.args.get('next') or url_for('admin.manage_whitelist')
            return redirect(next_page)
        else:
            flash("Identifiants invalides.")
    return render_template('admin/login.html')

@auth_bp.route('/logout')
def logout():
    session.pop('admin_logged_in', None)
    flash("Déconnexion réussie.")
    return redirect(url_for('auth.login'))
