from flask.testing import FlaskClient
import pytest
from kochan.core.app import app


@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as testClient:
        yield testClient


def test_root_route(testClient: FlaskClient):
    response = testClient.get("/")

    assert response.status_code == 200
