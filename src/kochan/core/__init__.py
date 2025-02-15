from sys import stdout
from types import ModuleType
from flask import Flask
from jinja2 import FileSystemLoader
from loguru import logger
import os
import importlib


def create_app():
    app = Flask(__name__)

    # replace logging with loguru (stonks!!!)
    app.logger = logger  # type: ignore

    # remove default sink
    app.logger.remove()

    app.logger.level("DEBUG", color="<blue>")
    app.logger.level("INFO", color="<green>")
    app.logger.level("WARNING", color="<yellow>")
    app.logger.level("ERROR", color="<red>")
    app.logger.level("CRITICAL", color="<red><bold>")

    app.logger.add(
        stdout,
        format="<blue>{time:HH:mm:ss.S}</blue> | <level>{level}</level> | <yellow>{module}:{line}</yellow> | {message}",
        level="INFO",
        enqueue=True,
    )

    app.logger.info("App initiated")

    ############
    #   Vars   #
    ############

    routes_dir = os.path.join(os.path.dirname(__file__), '..', 'routes')
    static_dir = os.path.join(os.path.dirname(__file__), "..", "static")
    templates_path = os.path.join(os.path.dirname(__file__), "..", "templates")

    ############
    #  Config  #
    ############

    app.logger.info("Configuring app")

    # Change dir with templates
    app.jinja_env.loader = FileSystemLoader(templates_path)

    app.config['SERVER_NAME'] = '0.0.0.0:8710'
    app.config['APPLICATION_ROOT'] = '/'
    app.config['STATIC_PATH'] = static_dir
    app.config['PREFERRED_URL_SCHEME'] = 'http'

    ############
    #  Routes  #
    ############

    app.logger.info("Configuring routes")

    for filename in os.listdir(routes_dir):
        if filename.endswith('.py') and filename != '__init__.py':
            module_name: str = filename[:-3]
            module: ModuleType = importlib.import_module(
                f'kochan.routes.{module_name}')
            if hasattr(module, f'{module_name}_bp'):
                blueprint = getattr(module, f'{module_name}_bp')
                app.register_blueprint(blueprint)

    return app
