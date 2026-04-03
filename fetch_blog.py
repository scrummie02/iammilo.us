import requests
PORTAINER = "http://192.168.200.220:9000"
PTR_KEY = "ptr_jVGvpkWmxmPusWm3yZYeEvMU8LLMvYjqDm8iLmsRQjk="
ENDPOINT = 6
CONTAINER_ID = "0ed088a96df4"

def get_file(path):
    headers = {"X-API-Key": PTR_KEY, "Content-Type": "application/json"}
    exec_url = f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/containers/{CONTAINER_ID}/exec"
    res = requests.post(exec_url, headers=headers, json={"AttachStdout": True, "Cmd": ["cat", path]})
    if res.status_code != 201: # Portainer returns 201 for Created
        return f"Error creating exec: {res.status_code} {res.text}"
    exec_id = res.json()["Id"]
    r = requests.post(f"{PORTAINER}/api/endpoints/{ENDPOINT}/docker/exec/{exec_id}/start",
                      headers=headers, json={"Detach": False, "Tty": False})
    return r.text

print("---INDEX---")
print(get_file("/usr/share/nginx/html/index.html"))
print("---ARCHIVE---")
print(get_file("/usr/share/nginx/html/archive.html"))
