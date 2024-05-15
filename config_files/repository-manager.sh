#!/bin/bash

# Função para adicionar um novo repositório

CONFIG_FILE=""

add_repository() {
    echo "Informe o URL do repositório Git:"
    read -r repo_url
    echo "Informe o nome da branch:"
    read -r branch
    echo "Informe o nome da imagem Docker:"
    read -r docker_image

    echo "Adicionando o repositório..."
    echo "REPO_URL=\"$repo_url\"" >> "$CONFIG_FILE"
    echo "BRANCH=\"$branch\"" >> "$CONFIG_FILE"
    echo "DOCKER_IMAGE=\"$docker_image\"" >> "$CONFIG_FILE"
    echo "Repositório adicionado com sucesso!"
}

list_repositories() {
    local found_repo=0
    local repo_url=""
    local branch=""

    while IFS= read -r line; do
        if [[ $found_repo -eq 1 ]]; then
            branch=$(echo "$line" | awk -F'"' '{print $2}')
            
            echo "Repositório: $repo_url (Branch: $branch)"
            echo "Último commit:"
            git ls-remote --heads "$repo_url" "$branch"
            git log --oneline -1
            echo "-----------------------------"

            create_repolocal "$repo_url" "$branch"
            found_repo=0 
        fi

        if [[ "$line" == REPO_URL=* ]]; then
            repo_url=$(echo "$line" | awk -F'"' '{print $2}')
            found_repo=1  
        fi
    done < "$CONFIG_FILE"
}

create_repolocal() {
    local repo_url=$1
    local branch=$2
    echo "Repository: $repo_url"
    echo "Branch: $branch"
    
    if [ ! -d "$(basename "$repo_url" .git)" ]; then
        echo "Clonando repositório..."
        pwd
        git clone --single-branch --branch "$branch" "$repo_url" "$(basename "$repo_url" .git)"
        ls -la
    else
        echo "O repositório já está na máquina local."
        update_repository
    fi
}

update_repository() {

    current_branch=$(git rev-parse --abbrev-ref HEAD)
    current_commit=$(git rev-parse HEAD)
    remote_commit=$(git ls-remote origin -h refs/heads/"$current_branch" | cut -f1)

    if [ "$current_commit" != "$remote_commit" ]; then
        echo "O commit local não está sincronizado com o commit remoto. Fazendo pull..."
        echo "Pull concluído."
    else
        echo "O commit local já está sincronizado com o commit remoto. Nenhuma ação necessária."
    fi
}


if [ ! -f "$CONFIG_FILE" ]; then
    touch "$CONFIG_FILE"
fi

# Menu de opções
while true; do
    echo "1. Adicionar novo repositório"
    echo "2. Listar repositórios e últimos commits"
    echo "3. Sair"
    read -rp "Escolha uma opção: " choice

    case $choice in
        1) add_repository ;;
        2) list_repositories ;;
        3) echo "Saindo do script." ; exit ;;
        *) echo "Opção inválida. Tente novamente." ;;
    esac
done
