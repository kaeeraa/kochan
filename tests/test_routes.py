from flask.testing import FlaskClient
import pytest
from kochan.core.app import app


@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client


def test_root_route(client: FlaskClient):
    response = client.get("/")

    assert response.status_code == 200
