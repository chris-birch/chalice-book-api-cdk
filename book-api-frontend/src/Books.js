import {useMutation,useQuery,useQueryClient} from 'react-query';
import Box from '@mui/material/Box';
import { DataGrid } from '@mui/x-data-grid';
import { useCallback } from 'react';
import Snackbar from '@mui/material/Snackbar';
const apiName = 'ChaliceAPI';
const path = '/books';
const myInit = {
  headers: {}, // OPTIONAL
  response: true, // OPTIONAL (return the entire Axios response object instead of only response.data)
  // queryStringParameters: {
  //   name: 'param' // OPTIONAL
  // }
};
// "isbn": 123123123,
//     "authors": "Christian Birch",
//     "original_publication_year": 1989,
//     "title": "What a wonderful worldx",
//     "language_code": "eng",
//     "average_rating": 5,
const columns = [
    {
        field: 'title',
        editable: true,
        preProcessEditCellProps: ({props}) => {
            return {...props, error: !props.value}
        }
    }, {
        field: 'authors',
        editable: true,
    }, {
        field: 'isbn',
        editable: true,
        valueSetter: ({row, value}) => ({...row, isbn: +value})
    }, {
        field: 'original_publication_year',
        editable: true,
        valueSetter: ({row, value}) => ({...row, original_publication_year: +value})
    }, {
        field: 'language_code',
        editable: true,
    }, {
        field: 'average_rating',
        editable: true,
        valueSetter: ({row, value}) => ({...row, average_rating: +value})
    }
]

function Books({api}) {
    const queryClient = useQueryClient();
    const {data, isLoading} = useQuery('books', async () => (await api.get(apiName, path, myInit)).data);

    const {mutate, isError, isSuccess} = useMutation(({id, ...book}) => {
        // set new value on cache, but retain old value
        return api.put(apiName, `${path}/${id}`, {body: book})
    }, {onSuccess: (response) => {
        // show toast success message
        queryClient.setQueryData('books', old => old.map(book => book.id === response.id ? response : book));
    }, onError: () => {
        // insert old value for book
        // show toast error message
    }})

    const processRowUpdate = useCallback(async (book, oldBook) => {
        mutate(book);
        return oldBook;
        //console.log(book);
    }, []);

    if (isLoading) return (<p>Loading...</p>);

    return (
        <>
            {isError && <Snackbar message="Error" />}
            {isSuccess && <Snackbar
  open={true}
  autoHideDuration={5000}
  message="Book saved"
/>}
        <Box sx={{height:500}}>
            <DataGrid columns={columns} rows={data} getRowId={(data) => data.book_id} experimentalFeatures={{ newEditingApi: true }} editMode="row" processRowUpdate={processRowUpdate}/>
        </Box>
        </>
    );
}
export default Books;
