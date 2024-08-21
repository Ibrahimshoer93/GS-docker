from flask import Flask, request, jsonify
import subprocess
import os

app = Flask(__name__)

def run_training(folder_path):
    command = f"python train.py -s {folder_path} --model_path {folder_path}/output/"
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    return stdout.decode(), stderr.decode()

@app.route('/run-training', methods=['POST'])
def run_training_endpoint():
    data = request.json
    folder_path = data.get('folder_path')
    if not folder_path:
        return jsonify({"error": "Folder path is required"}), 400

    # Prefix the folder_path with the mounted directory path
    full_path = os.path.join("/workspace/data", folder_path)

    if not os.path.exists(full_path):
        return jsonify({"error": f"Folder path '{full_path}' does not exist"}), 400

    # Run the training command
    stdout, stderr = run_training(full_path)

    if stderr:
        return jsonify({"error": stderr}), 500

    return jsonify({"message": "Training completed", "output": stdout})
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
