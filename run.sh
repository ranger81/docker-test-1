#! /bin/bash

# Make sure the working directory is set to the path of the run.sh
cd "$(dirname "$0")"

if [ "$1" == "update" ]
then
    echo "Updating stack"
    # Show confirmation dialog
    read -p "This will overwrite local changes (except env folder). Are you sure? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Pull latest version from GitHub repository (but keep env folder)
        git stash push -- ./env/ # Put files in the ./env/ folder onto stash
        git pull --no-rebase # Pull latest code from GitHub
        git restore --source='stash@{0}' . # Restore files, which were previously put ont stash

        # Stop running stack
        docker compose --env-file ./env/general.env down
        # Start new stack and force recreation of images
        docker compose --env-file ./env/general.env up --build -d
    else
        echo "Process canceled!"
    fi
elif [ "$1" == "start" ]
then
    echo "Restarting stack"
    docker compose --env-file ./env/general.env down
    docker compose --env-file ./env/general.env up -d
elif [ "$1" == "stop" ]
then
    echo "Stopping stack"
    docker compose --env-file ./env/general.env down
else
    echo "Use one of the following parameters: start, stop, update"
fi