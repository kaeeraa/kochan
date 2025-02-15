from flask import Blueprint, Response, render_template, send_from_directory
from kochan.routes import css_path

index_bp = Blueprint("index", __name__)


@index_bp.route("/")
def index() -> str:
    """index HTML file of /

    Returns:
        str: jinja2 template
    """
    return render_template("index.html")


@index_bp.route("/static/index.css")
def index_css() -> Response:
    """index CSS file of /

    Returns:
        Response: css file
    """
    return send_from_directory(css_path, "index.css")
