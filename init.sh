#!/bin/bash

aniblePublicKey= # INPUT PUBLIC KEY HERE
macbookPublicKey= # INPUT PUBLIC KEY HERE
# Function to prompt for password securely
get_password() {
    read -s -p "Enter password: " password
    echo
}

# Function to create Ansible user and set up SSH
setup_ansible_user() {
    echo "> Adding Ansible user"
    useradd ansible

    echo "> Setting password for the Ansible user"
    get_password

    # Set the password for the new user
    echo "ansible:$password" | chpasswd

    echo "> Making Ansible home directory"
    mkdir -p /home/ansible

    echo "> Making SSH directory"
    mkdir -p /home/ansible/.ssh

    echo "> Creating authorized_keys file"
    echo "ssh-rsa $macbookPublicKey" > /home/ansible/.ssh/authorized_keys

    echo "> Changing permissions for home directory to Ansible"
    chown -R ansible:root /home/ansible/

    echo "> Adding Ansible user to sudoers"
    echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
}

# Main script logic
while true; do
    echo "Is this the Ansible host? (y/n)"
    read answer
    answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]' | xargs) # Convert input to lowercase

    if [ "$answer" == "y" ]; then
        echo "> Configuring Ansible host"
        if [ -f /home/ansible/.ssh/ansible ]; then
            read -p "Generating public/private rsa key pair. /home/ansible/.ssh/ansible already exists. Overwrite (y/n)? " option
            while true; do
            if [[ "$option" == [yY] ]]; then
                mv /home/ansible/.ssh/ansible /home/ansible/.ssh/ansible.bak
                mv /home/ansible/.ssh/ansible.pub /home/ansible/.ssh/ansible.pub.bak
                ssh-keygen -t rsa -m PEM -f /home/ansible/.ssh/ansible -N "" -q
                echo "SSH key generated successfully"
                break # exit the loop
            elif [[ "$option" == [nN] ]]; then
                echo "SSH key generation aborted"
                break # exit the loop
            else
                echo "Fuck you"
            fi
            done
            mv /home/ansible/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys.bak
            echo "V$ansiblePublicKey" > /home/ansible/.ssh/authorized_keys
        else
            ssh-keygen -t rsa -m PEM -f /home/ansible/.ssh/ansible -N "" -q
            echo "SSH key generated successfully"
            mv /home/ansible/.ssh/authorized_keys /home/ansible/.ssh/authorized_keys.bak
            echo "V$ansiblePublicKey" > /home/ansible/.ssh/authorized_keys
        fi
        if ! [ -f /etc/sudoers.d/ansible ]; then
            echo '> Adding sudoer'
            echo
            echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
        fi
        if [ -f $PWD/inventory.ini ]; then
            echo '> make inventory file based on example'
            echo 
            mv $PWD/inventory.ini $PWD/inventory.ini.bak
            cp $PWD/inventory.ini.example $PWD/inventory.ini
        elif [ -f $PWD/inventory ]; then
            echo '> make inventory file based on example'
            echo 
            mv $PWD/inventory $PWD/inventory.bak
            cp $PWD/inventory.ini.example $PWD/inventory.ini
        else
            echo '> make inventory file based on example'
            echo 
            cp $PWD/inventory.ini.example inventory.ini
        fi

        echo "> Making test directory and test yaml file"
        mkdir -p "$PWD/test"
        touch "$PWD/test.yml"
        echo "> Configuration completed for Ansible host"
        break
    elif [ "$answer" == "n" ]; then
        setup_ansible_user
        break
    else
        echo "Invalid input. Please enter 'y' or 'n'."
    fi
done

echo "> Configuration completed."
