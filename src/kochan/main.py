from kochan.core.app import app


def run() -> None:
    """Run Flask app"""
    app.run(
        host="0.0.0.0",
        port=8710,
    )


if __name__ == "__main__":
    run()
