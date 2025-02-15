from flask import Blueprint, Response, send_from_directory
from kochan.routes import images_path

favicon_bp = Blueprint("favicon", __name__)


@favicon_bp.route("/favicon.ico")
def favicon() -> Response:
    """Favicon of website

    Returns:
        Response: file with favicon
    """
    return send_from_directory(images_path, "favicon.ico")
