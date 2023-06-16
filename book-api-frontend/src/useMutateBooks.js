import { useMutation, useQueryClient } from "react-query";

import { createBook, deleteBook, updateBook } from './book-api';

export const useMutateBooks = () => {
  const queryClient = useQueryClient();

  return useMutation(({ action, book }) => {
    switch (action) {
      case 'create':
        return createBook(book);

      case 'update':
        return updateBook(book);

      case 'delete':
        return deleteBook(book);

      default:
        throw new Error('Invalid action');
    }
  }, {
    onMutate: async ({action, book}) => {
      // todo maybe only store and restore the book we are actually mutating, especially if offline mode/dodgy connection was supported.
      const previous = queryClient.getQueryData(['books']);

      await queryClient.cancelQueries({ queryKey: ['books'] });
 
      switch (action) {
        case 'create':
          queryClient.setQueryData(['books'], (old) => [...old, book]);
          break;

        case 'update':
          queryClient.setQueryData(['books'], (old) => old.map(iBook => iBook.book_id !== book.book_id ? iBook : book));
          break;
  
        case 'delete':
          queryClient.setQueryData(['books'], (old) => old.filter(iBook => iBook.book_id !== book.book_id));
          break;

        default:
          throw new Error('Invalid action');
      }
  
      return { previous }
    },
    onError: (_err, _data, context) => {
      // Revert optimistic updates.
      queryClient.setQueryData(['books'], context.previous);
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: ['books'] })
    },
  });
}
