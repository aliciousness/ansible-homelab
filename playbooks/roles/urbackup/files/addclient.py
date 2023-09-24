import urbackup_api
import sys

def add_extra_client(hostname, password, client_name):
    server_url = f"http://{hostname}:55414/x"
    server = urbackup_api.urbackup_server(server_url, "admin", password)
    server.add_extra_client(client_name)
    print(f"Added extra client '{client_name}' successfully.")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python script_name.py hostname password client_name")
        sys.exit(1)

    hostname = sys.argv[1]
    password = sys.argv[2]
    client_name = sys.argv[3]

    add_extra_client(hostname, password, client_name)
