from flask import Flask, request, jsonify
import subprocess
import os
import threading

app = Flask(__name__)
training_lock = threading.Lock()

def run_training(folder_path):
    command = f"python train.py -s {folder_path} --model_path {folder_path}/output/"
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    return stdout.decode(), stderr.decode()

@app.route('/run-training', methods=['POST'])
def run_training_endpoint():
    if training_lock.locked():
        return jsonify({"error": "Server is currently busy"}), 429

    data = request.json
    folder_path = data.get('folder_path')
    if not folder_path:
        return jsonify({"error": "Folder path is required"}), 400

    # Prefix the folder_path with the mounted directory path
    full_path = os.path.join("/workspace/data", folder_path)

    if not os.path.exists(full_path):
        return jsonify({"error": f"Folder path '{full_path}' does not exist"}), 400

    training_lock.acquire()
    try:
        # Run the training command
        stdout, stderr = run_training(full_path)
        if stderr:
            return jsonify({"error": stderr}), 500
        return jsonify({"message": "Training completed", "output": stdout})
    finally:
        training_lock.release()

@app.route('/status', methods=['GET'])
def status():
    if training_lock.locked():
        return jsonify({"status": "busy"}), 500
    else:
        return jsonify({"status": "idle"}), 200

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "Machine is up and running"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

