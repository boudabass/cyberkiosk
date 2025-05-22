from flask import Blueprint, render_template, request, redirect, url_for, flash
from .whitelist import get_whitelist, add_domain, remove_domain

admin_bp = Blueprint('admin', __name__, url_prefix='/admin')

@admin_bp.route('/whitelist', methods=['GET', 'POST'])
def manage_whitelist():
    if request.method == 'POST':
        action = request.form.get('action')
        domain = request.form.get('domain', '').strip()
        if action == 'add' and domain:
            add_domain(domain)
            flash(f"Domaine ajouté à la whitelist : {domain}")
        elif action == 'remove' and domain:
            remove_domain(domain)
            flash(f"Domaine supprimé de la whitelist : {domain}")
        return redirect(url_for('admin.manage_whitelist'))
    whitelist = get_whitelist()
    return render_template('admin/whitelist.html', whitelist=whitelist)
