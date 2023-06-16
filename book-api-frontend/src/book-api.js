import { API } from 'aws-amplify';

const apiName = 'ChaliceAPI';
const path = '/books';

export const getBooks = async () => API.get(apiName, path);

export const createBook = async (book) => API.post(apiName, path, {body: book});

export const updateBook = async (book) => API.put(apiName, `${path}/${book.book_id}`, {body: book});

export const deleteBook = async (book) => API.del(apiName, `${path}/${book.book_id}`);
