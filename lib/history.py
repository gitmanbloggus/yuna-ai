import json
import os
import shutil
import subprocess
from cryptography.fernet import Fernet, InvalidToken

class ChatHistoryManager:
    def __init__(self, config):
        self.config = config
        self.base_history_path = "db/history"  # Base path for histories

    def _user_folder_path(self, username):
        """Constructs the path to the user's folder."""
        print(f"Username: {username}")
        return os.path.join(self.base_history_path, username)

    def _ensure_user_folder_exists(self, username):
        """Ensures that the user-specific folder exists."""
        user_folder_path = self._user_folder_path(username)
        os.makedirs(user_folder_path, exist_ok=True)
        return user_folder_path

    def create_chat_history_file(self, username, chat_id):
        user_folder_path = self._ensure_user_folder_exists(username)
        history_file_path = os.path.join(user_folder_path, f"{chat_id}")  # File path includes username folder
        history_starting_template = [
            {"name": self.config['ai']['names'][0], "message": "Hi"}, 
            {"name": self.config['ai']['names'][1], "message": "Hello"},
            {"name": self.config['ai']['names'][0], "message": "How are you doing?"}, 
            {"name": self.config['ai']['names'][1], "message": "I'm doing great! Thanks for asking!"}
        ]
        chat_history_json = json.dumps(history_starting_template)
        encrypted_chat_history = self.encrypt_data(chat_history_json)
        with open(history_file_path, 'wb') as file:
            file.write(encrypted_chat_history)

    def save_chat_history(self, chat_history, username, chat_id):
        user_folder_path = self._ensure_user_folder_exists(username)
        history_file_path = os.path.join(user_folder_path, f"{chat_id}")
        chat_history_json = json.dumps(chat_history)
        encrypted_chat_history = self.encrypt_data(chat_history_json)
        with open(history_file_path, 'wb') as file:
            file.write(encrypted_chat_history)

    def load_chat_history(self, username, chat_id):
        user_folder_path = self._ensure_user_folder_exists(username)
        history_file_path = os.path.join(user_folder_path, f"{chat_id}")
        try:
            with open(history_file_path, 'rb') as file:
                encrypted_chat_history = file.read()
            decrypted_chat_history = self.decrypt_data(encrypted_chat_history)
            return json.loads(decrypted_chat_history)
        except FileNotFoundError:
            # The file does not exist, create a new chat history file
            self.create_chat_history_file(username, chat_id)
            return []

    def delete_chat_history_file(self, username, chat_id):
        chat_history_path = os.path.join(self._user_folder_path(username), f"{chat_id}")
        if os.path.exists(chat_history_path):
            os.remove(chat_history_path)

    def rename_chat_history_file(self, username, old_chat_id, new_chat_id):
        old_path = os.path.join(self._user_folder_path(username), f"{old_chat_id}")
        new_path = os.path.join(self._user_folder_path(username), f"{new_chat_id}")
        if os.path.exists(old_path):
            os.rename(old_path, new_path)

    def list_history_files(self, username):
        user_folder_path = self._user_folder_path(username)
        if not os.path.isdir(user_folder_path):
            return []  # Return an empty list if the user's folder doesn't exist
        
        print(f"User folder path: {user_folder_path}")

        # List only files in the user's directory, excluding directories
        history_files = [f for f in os.listdir(user_folder_path) if os.path.isfile(os.path.join(user_folder_path, f))]

        print(f"History files: {history_files}")

        # Sort alphabetically
        history_files.sort(key=lambda x: x.lower())
        return history_files

    def generate_speech(self, response):
        subprocess.run(f'say "{response}" -o output', shell=True)
        shutil.move("output.aiff", "/audio/output.aiff")
        subprocess.run(f"ffmpeg -y -i '/audio/output.aiff' -b:a 192K -f mp3 static/audio/output.mp3", shell=True)

    def get_encryption_key(self):
        if 'encryption_key' not in self.config['security'] or not self.config['security']['encryption_key']:
            new_key = Fernet.generate_key()
            self.config['security']['encryption_key'] = new_key.decode()
            self.save_config()
        key = self.config['security']['encryption_key']
        return key.encode()

    def save_config(self):
        with open('static/config', 'w') as config_file:
            json.dump(self.config, config_file, indent=4)

    def encrypt_data(self, data):
        key = self.get_encryption_key()
        fernet = Fernet(key)
        encrypted_data = fernet.encrypt(data.encode())
        return encrypted_data

    def decrypt_data(self, encrypted_data):
        try:
            key = self.get_encryption_key()
            fernet = Fernet(key)
            decrypted_data = fernet.decrypt(encrypted_data)
        except InvalidToken:
            raise ValueError("Cannot decrypt data with the current encryption key")
        return decrypted_data