from flask import Blueprint, render_template, send_from_directory
from kochan.routes import css_path

index_bp = Blueprint("index", __name__)

#############
# HTML file #
#############


@index_bp.route("/")
def index() -> str:
    return render_template("index.html")

############
# CSS file #
############


@index_bp.route("/static/index.css")
def index_css():
    return send_from_directory(css_path, "index.css")
