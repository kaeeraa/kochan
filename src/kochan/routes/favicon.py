from flask import Blueprint, Response, send_from_directory
from kochan.routes import images_path

favicon_bp = Blueprint("favicon", __name__)


@favicon_bp.route("/favicon.ico")
def favicon() -> Response:
    return send_from_directory(images_path, "favicon.ico")
