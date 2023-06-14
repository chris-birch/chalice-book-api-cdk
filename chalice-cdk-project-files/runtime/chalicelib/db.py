import os
import ulid

from chalice import ChaliceViewError

from pynamodb.models import Model
from pynamodb.attributes import UnicodeAttribute, NumberAttribute
from pynamodb.exceptions import ScanError, PutError, DoesNotExist, GetError, DeleteError

from devtools import debug

DYNAMODB_HOST = "http://localhost:8000"
DYNAMODB_REGION = os.getenv("AWS_REGION", "eu-west-2")
DYNAMODB_TABLE_NAME = os.getenv("APP_TABLE_NAME", "Books")

def uiud():
    uiud = ulid.new()
    return uiud.str

class BookDbModel(Model):
    """
    The 'Book' data model
    """
    class Meta:
        table_name = DYNAMODB_TABLE_NAME
        region = DYNAMODB_REGION

        # Only set 'host' var if we're running locally
        if 'AWS_CHALICE_CLI_MODE' in os.environ: host = DYNAMODB_HOST

    pk = UnicodeAttribute(hash_key=True, default=uiud)
    book_id = NumberAttribute()
    isbn = NumberAttribute()
    authors = UnicodeAttribute()
    original_publication_year = NumberAttribute()
    title = UnicodeAttribute()
    language_code = UnicodeAttribute()
    average_rating = NumberAttribute()

"""
The Book Class ...
"""
class Book:
    def allBooks():
        """
        Scan DynamoDB for all books and return the result
        """
        scan_results = list()
        try: 
            for item in BookDbModel.scan():
                scan_results.append(item.attribute_values)
            
            return (tuple(scan_results))

        except ScanError as se:
            print(se)
            raise ChaliceViewError(ScanError.msg)


    def save(book_list: list):
        with BookDbModel.batch_write() as batch:
            threads = []
            
            for book in book_list:
                thread = BookDbModel(book_id=book['book_id'],
                            isbn=book['isbn'],
                            authors=book['authors'],
                            original_publication_year=book['original_publication_year'],
                            title=book['title'],
                            language_code=book['language_code'],
                            average_rating=book['average_rating'])
                threads.append(thread)
            
            try:
                for item in threads:
                    batch.save(item)

            except PutError as pe:
                print (pe)
                raise ChaliceViewError(PutError.msg)

    def findByPk(pk: str):
        try:
            return BookDbModel.get(pk)
        
        except DoesNotExist:
            raise
        
        except GetError as ge:
            print(ge)
            raise ChaliceViewError(GetError.msg)
        
    def bookId(book_id: int):
            scan_results = []
            
            try: 
                for book in BookDbModel.scan(BookDbModel.book_id == book_id):
                    scan_results.append(book.attribute_values)
            
            except ScanError as se:
                print(se)
                raise ChaliceViewError(ScanError.msg)
        
            return scan_results
    

    def allBookIds() -> tuple:
        scan_results = list()
        try: 
            for item in BookDbModel.scan():
                scan_results.append(item.book_id)
            
            return (tuple(scan_results))

        except ScanError as se:
            print(se)
            raise ChaliceViewError(ScanError.msg)
    

    def update(item_pk, book):
        try: 
            book = BookDbModel( pk=item_pk,
                                book_id=book['book_id'],
                                isbn=book['isbn'],
                                authors=book['authors'],
                                original_publication_year=book['original_publication_year'],
                                title=book['title'],
                                language_code=book['language_code'],
                                average_rating=book['average_rating'])
            
            book.save(BookDbModel.pk.exists())
        
        except PutError as pe:
            if "ConditionalCheckFailedException" in pe.msg:
                raise DoesNotExist
            
            else:
                print(pe)
                raise ChaliceViewError(PutError.msg)
            
        
    def delete(item_pk):
        try: 
            book = BookDbModel(pk=item_pk)
            book.delete(BookDbModel.pk.exists())
        
        except DeleteError as de:
            if "ConditionalCheckFailedException" in de.msg:
                raise DoesNotExist
            
            else:
                print(de)
                raise ChaliceViewError(PutError.msg)        