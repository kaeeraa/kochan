from types import ModuleType
from flask import Flask
import os
import importlib


def create_app():
    app = Flask(__name__)

    routes_dir = os.path.join(os.path.dirname(__file__), '..', 'routes')

    for filename in os.listdir(routes_dir):
        if filename.endswith('.py') and filename != '__init__.py':
            module_name: str = filename[:-3]
            module: ModuleType = importlib.import_module(f'kochan.routes.{module_name}')
            if hasattr(module, f'{module_name}_bp'):
                blueprint = getattr(module, f'{module_name}_bp')
                app.register_blueprint(blueprint)

    return app
