import os
import subprocess

PRIVOXY_USER_ACTION = '/app/privoxy/user.action'
PRIVOXY_CONTAINER_NAME = os.environ.get('PRIVOXY_CONTAINER_NAME', 'cyberkiosk-privoxy')

def get_whitelist():
    """Retourne la liste des domaines autorisés dans la whitelist."""
    whitelist = []
    with open(PRIVOXY_USER_ACTION, 'r') as f:
        for line in f:
            line = line.strip()
            if line.startswith('{-block}'):
                domain = line.replace('{-block}', '').strip().strip('/')
                if domain:
                    whitelist.append(domain)
    return whitelist

def add_domain(domain):
    """Ajoute un domaine à la whitelist si non présent."""
    domains = get_whitelist()
    if domain not in domains:
        with open(PRIVOXY_USER_ACTION, 'a') as f:
            f.write(f"\n{{-block}}\n{domain}/\n")
        reload_privoxy()

def remove_domain(domain):
    """Supprime un domaine de la whitelist."""
    lines = []
    with open(PRIVOXY_USER_ACTION, 'r') as f:
        skip = False
        for line in f:
            if line.strip() == '{-block}':
                skip = True
                continue
            if skip and line.strip().startswith(domain):
                skip = False
                continue
            if skip:
                skip = False
                continue
            lines.append(line)
    with open(PRIVOXY_USER_ACTION, 'w') as f:
        f.writelines(lines)
    reload_privoxy()

def reload_privoxy():
    """Redémarre le conteneur Privoxy pour recharger la whitelist."""
    subprocess.run(['docker', 'restart', PRIVOXY_CONTAINER_NAME], check=True)
