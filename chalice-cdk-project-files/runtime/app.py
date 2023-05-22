from chalice import Chalice, IAMAuthorizer, Response, NotFoundError, BadRequestError

from pynamodb.exceptions import DoesNotExist
from pydantic import BaseModel, ValidationError, validator
from typing import List

from chalicelib.db import Book

from devtools import debug

authorizer = IAMAuthorizer()
app = Chalice(app_name='chalice-cdk-project-files')

class BookPyModel(BaseModel):
    book_id: int
    isbn: int
    authors: str
    original_publication_year: int
    title: str
    language_code: str
    average_rating: float

class BookPyList(BaseModel):
    data: List[BookPyModel]

    @validator('data')
    def book_id_must_be_unique(cls, book_object_list):
        book_ids = set()
        for book_object in book_object_list:

            if book_object.book_id in book_ids:
                raise ValueError("Duplicate book_id {} found".format(book_object.book_id))
            
            book_ids.add(book_object.book_id)

        return book_object_list

## Get all books || Or query by book ID
@app.route('/books', methods=['GET'])
def get_all_books():
    if app.current_request.query_params:
        query_parameters = app.current_request.to_dict()['query_params']
        
        if 'book_id' in query_parameters:
            book_id = int(query_parameters['book_id'])
            scan_result = Book.bookId(book_id)

            if len(scan_result) != 0:
                return scan_result
            else:
                raise NotFoundError("No book found by that ID")
            
        else:
            raise BadRequestError("Only the 'book_id' query parameter is supported")
    
    else:
        return Book.allBooks()


## Create a new book
@app.route('/books', methods=['POST'],content_types=['application/json'])
def books_post():
    request_body = app.current_request.json_body

    try:
        book_list = BookPyList(**request_body).dict()
        
        # Check that book_id(s) don't already exisit in the db
        book_ids_in_body = set()
        for each_book in book_list['data']:
            book_ids_in_body.add(each_book['book_id'])

        ids_already_in_db = book_ids_in_body.intersection(set(Book.allBookIds()))

        if len(ids_already_in_db) == 0:
            Book.save(book_list['data'])
        else:
            raise BadRequestError("The following Book IDs already exist in the database: {}".format(ids_already_in_db))

    except ValidationError as ve:
        return Response(body=ve.json(), status_code=400)
    
    except TypeError as te:
        print (te)
        raise BadRequestError("Malformed request body")
    
    else:
        return Response(body="", status_code=201)


## Get book by PK 
@app.route('/books/{pk}', methods=['GET'])
def books(pk: str):
    try:
        return Book.findByPk(pk).attribute_values

    except DoesNotExist:
        raise NotFoundError("Book not found with that PK")


## Update a single book
@app.route('/books/{pk}', methods=['PUT'], content_types=['application/json'], authorizer=authorizer)
def books_put(pk: str):
    request_body = app.current_request.json_body

    try:
        book_data = BookPyModel(**request_body).dict()
        Book.update(pk, book_data)

    except ValidationError as ve:
        return Response(body=ve.json(), status_code=400)
    
    except DoesNotExist:
        raise NotFoundError("Book not found with that PK")
    
    else:
        return Response(body="", status_code=204)

## Delete a single book
@app.route('/books/{pk}', methods=['DELETE'], authorizer=authorizer)
def books_delete(pk: int):
    try:
        Book.delete(pk)
    
    except DoesNotExist:
        raise NotFoundError("Book not found with that PK")
    
    else:
        return Response(body="", status_code=204)


## Lambda function to handle CSV imports via an S3 bucket
@app.lambda_function(name='MyFunction')
def other_lambda_function(event, context):
    
    debug(event)
    print("############################")
    debug(context)


    #TODO This needs to handle multiple files
    s3_file_upload_name = event['Records'][0]['s3']['object']['key']
    
    # try:
    #     # TODO Validate that we have the correct CSV file(s)
    #     csv_file = s3.Bucket(S3_IMPORT_BUCKET).Object(s3_file_upload_name).get()
        
    #     try:
    #         foo = read_csv(csv_file['Body'], on_bad_lines='skip')
    #         foo['isbn'] = to_numeric(foo['isbn'], errors='coerce', downcast='signed')
            
    #         batchLoadDataFromJson((foo.to_json(orient="records")))
    #     except ValueError as e:
    #         print(e)

    # except Exception as e:
    #     print(e)