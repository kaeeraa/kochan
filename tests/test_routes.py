import pytest
from flask.testing import FlaskClient

from kochan.core.app import app


@pytest.fixture
def client():
    """Generate Flask client for testing

    Yields:
        FlaskClient: an test client for Flask
    """
    app.config["TESTING"] = True
    with app.test_client() as testClient:
        yield testClient


def test_root_route(client: FlaskClient):
    """Test / route

    Args:
        testClient (FlaskClient): an test client for Flask
    """
    response = client.get("/")

    assert response.status_code == 200
