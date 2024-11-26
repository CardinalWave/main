import os
import shutil
import subprocess

DOCKER_COMPOSE_FILE = 'docker-compose.yml'

REPOSITORIES = [
    {'url': 'https://github.com/CardinalWave/mqtt-mosquitto.git', 'branch': 'main'},
    {'url': 'https://github.com/CardinalWave/nginx.git', 'branch': 'main'},
    {'url': 'https://github.com/CardinalWave/cw_message_db.git', 'branch': 'server'},
    {'url': 'https://github.com/CardinalWave/cw_central_db.git', 'branch': 'server'},
    {'url': 'https://github.com/CardinalWave/cw-bff-service.git', 'branch': 'main'},
    {'url': 'https://github.com/CardinalWave/cw-log-trace.git', 'branch': 'master'},
    {'url': 'https://github.com/CardinalWave/cw-message-service.git', 'branch': 'master'},
    {'url': 'https://github.com/CardinalWave/cw-central-service.git', 'branch': 'master'},
    {'url': 'https://github.com/CardinalWave/cw-mqtt-gateway.git', 'branch': 'main'},
    {'url': 'https://github.com/CardinalWave/cw-auth-service.git', 'branch': 'master'},
    {'url': 'https://github.com/CardinalWave/python-base-image.git', 'branch': 'main'},
    {'url': 'https://github.com/CardinalWave/keycloak.git', 'branch': 'main'},

 ]

DEST_DIR = 'cardinal_wave'

if not os.path.exists(DEST_DIR):
    os.makedirs(DEST_DIR)

def clone_repositories(repos, dest_dir):
    for repo in repos:
        clone_url = repo['url']
        branch = repo['branch']
        repo_name = clone_url.split('/')[-1].replace('.git', '')
        repo_path = os.path.join(dest_dir, repo_name)

        if not os.path.exists(repo_path):
            print(f'Clonando {repo_name} na branch {branch}...')
            subprocess.run(['git', 'clone', clone_url, repo_path])
            subprocess.run(['git', 'checkout', branch], cwd=repo_path)
        else:
            print(f'Clonando {repo_name} na branch {branch}...')
            subprocess.run(['git', 'fetch'], cwd=repo_path)
            subprocess.run(['git', 'checkout', branch], cwd=repo_path)

def copy_docker_compose(target_path):
    if os.path.isfile(DOCKER_COMPOSE_FILE):
        shutil.copy(DOCKER_COMPOSE_FILE, target_path)
        print(f'Arquivo {DOCKER_COMPOSE_FILE} copiado para {target_path}')
    else:
        print(f'O arquivo {DOCKER_COMPOSE_FILE} não foi encontrado no diretorio atual')

def main():
    print('Obtendo repositorios da lista...')
    clone_repositories(REPOSITORIES, DEST_DIR)
    print('Processo concluido.')
    copy_docker_compose(DEST_DIR)

 
if __name__ == '__main__':
    main()
