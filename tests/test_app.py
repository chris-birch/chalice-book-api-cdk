## NOTE: Path to the runtime folder has been added in tests/__init__.py ##

import os
import json
from devtools import debug

from chalice.test import Client

# DYNAMODB_HOST = "http://localhost:8000" in db.py by setting below env var.
os.environ['AWS_CHALICE_CLI_MODE'] = 'TRUE'

from app import app

def test_get_all_books():
    with Client(app) as client:
        response = client.http.get('/books')
        assert response.status_code == 200
        assert response.json_body == [
            {
                "pk": "01GXTJDR8MCPWV15RXVRBCFKWW",
                "authors": "Scott Westerfeld",
                "average_rating": 3.86,
                "book_id": 9,
                "isbn": 68986533,
                "language_code": "eng",
                "original_publication_year": 2006,
                "title": "Uglies (Uglies, #1)"
            },
            {
                "pk": "01GXTJDR8NEZMXKKS4NXGYT8QA",
                "authors": "William Shakespeare",
                "average_rating": 3.88,
                "book_id": 154,
                "isbn": 743477103,
                "language_code": "eng",
                "original_publication_year": 1606,
                "title": "Macbeth"
            },
            {
                "pk": "01GVKMWCH976MA7AZBTVXCHBSY",
                "authors": "Anita Diamant",
                "average_rating": 4.16,
                "book_id": 150,
                "isbn": 312353766,
                "language_code": "en-US",
                "original_publication_year": 1997,
                "title": "The Red Tent"
            }
        ]

def test_query_book_by_id():
    with Client(app) as client:
        response = client.http.get('/books?book_id=150')
        assert response.status_code == 200
        assert response.json_body == [{
                "pk": "01GVKMWCH976MA7AZBTVXCHBSY",
                "authors": "Anita Diamant",
                "average_rating": 4.16,
                "book_id": 150,
                "isbn": 312353766,
                "language_code": "en-US",
                "original_publication_year": 1997,
                "title": "The Red Tent"
            }]

def test_query_book_by_id_none_found():
    with Client(app) as client:
        response = client.http.get('/books?book_id=43')
        assert response.status_code == 404                                       

def test_invalid_books_query():
    with Client(app) as client:
        response = client.http.get('/books?wrong=query')
        assert response.status_code == 400

def test_create_new_book():
    with Client(app) as client:
        response = client.http.post(
            path = '/books', 
            headers={'Content-Type': 'application/json'}, 
            body=json.dumps(
                {"data":[
                        {
                            "book_id":122,
                            "isbn":60987103,
                            "authors":"Gregory Maguire, Douglas Smith",
                            "original_publication_year":1994,
                            "title":"Wicked: The Life and Times of the Wicked Witch of the West (The Wicked Years, #1)",
                            "language_code":"eng",
                            "average_rating":3.52   
                        }
                    ]
                }
            )
        )

        assert response.status_code == 201

def test_create_new_book_id_already_exists():
    with Client(app) as client:
        response = client.http.post(
            path = '/books', 
            headers={'Content-Type': 'application/json'}, 
            body=json.dumps(
                {"data":[
                        {
                            "book_id":9,
                            "isbn":60987103,
                            "authors":"Gregory Maguire, Douglas Smith",
                            "original_publication_year":1994,
                            "title":"Wicked: The Life and Times of the Wicked Witch of the West (The Wicked Years, #1)",
                            "language_code":"eng",
                            "average_rating":3.52   
                        }
                    ]
                }
            )
        )

        assert response.status_code == 400

def test_create_new_book_invalid_body():
    with Client(app) as client:
        response = client.http.post(
            path = '/books', 
            headers={'Content-Type': 'application/json'}, 
            body=json.dumps(
                {"data":[
                        {
                            "book_id":223,
                            "isbn":60987103,
                            "authors":"Gregory Maguire, Douglas Smith",
                            "original_publication_year":1994,
                            "title":"Wicked: The Life and Times of the Wicked Witch of the West (The Wicked Years, #1)",
                            #"language_code":"eng",
                            "average_rating":3.52
                        }
                    ]
                }
            )
        )

        assert response.status_code == 400

def test_get_by_pk():
    with Client(app) as client:
        response = client.http.get('/books/01GVKMWCH976MA7AZBTVXCHBSY')
        assert response.status_code == 200

def test_get_by_pk_not_found():
    with Client(app) as client:
        response = client.http.get('/books/Z1GVKMWCH976MA7AZBTVXCKBSY')
        assert response.status_code == 500


def test_update_by_pk():
    with Client(app) as client:
        response = client.http.put(
            path = '/books/01GVKMWCH976MA7AZBTVXCHBSY', 
            headers={'Content-Type': 'application/json'}, 
            body=json.dumps(
                {
                    "book_id":150,
                    "isbn":60987103,
                    "authors":"Gregory Maguire, Douglas Smith",
                    "original_publication_year":1994,
                    "title":"Wicked: The Life and Times of the Wicked Witch of the West (The Wicked Years, #1)",
                    "language_code":"eng",
                    "average_rating":3.52   
                }
            )
        )

        assert response.status_code == 204


def test_update_by_pk_differant_store_id():
    with Client(app) as client:
        response = client.http.put(
            path = '/books/01GVKMWCH976MA7AZBTVXCHBSY', 
            headers={'Content-Type': 'application/json'}, 
            body=json.dumps(
                {
                    "book_id":4,
                    "isbn":60987103,
                    "authors":"Gregory Maguire, Douglas Smith",
                    "original_publication_year":1994,
                    "title":"Wicked: The Life and Times of the Wicked Witch of the West (The Wicked Years, #1)",
                    "language_code":"eng",
                    "average_rating":3.52   
                }
            )
        )

        assert response.status_code == 400

def test_update_by_pk_invalid_body():
    with Client(app) as client:
        response = client.http.put(
            path = '/books/01GVKMWCH976MA7AZBTVXCHBSY', 
            headers={'Content-Type': 'application/json'}, 
            body=json.dumps(
                {
                    "book_id":150,
                    #"isbn":60987103,
                    "authors":"Gregory Maguire, Douglas Smith",
                    "original_publication_year":1994,
                    "title":"Wicked: The Life and Times of the Wicked Witch of the West (The Wicked Years, #1)",
                    "language_code":"eng",
                    "average_rating":3.52   
                }
            )
        )

        assert response.status_code == 400

def test_update_by_pk_not_found():
    with Client(app) as client:
        response = client.http.put('/books/Z1GVKMWCH976MA7AZBTVXCKBSD')
        assert response.status_code == 404


def test_delete_by_pk():
    with Client(app) as client:
        response = client.http.delete('/books/01GXTJDR8NEZMXKKS4NXGYT8QA')
        assert response.status_code == 204

def test_delete_by_pk_not_found():
    with Client(app) as client:
        response = client.http.put('/books/Z1GVKMWCHJ76MA7AZBTVXUKBSD')
        assert response.status_code == 404