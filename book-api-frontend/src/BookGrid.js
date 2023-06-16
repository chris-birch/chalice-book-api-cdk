/**
 * @todo Input configuration such as columns
 * @todo Validation
 * @todo Restructure
 * @todo Test
 */

import { useLayoutEffect, useRef, useState } from 'react';
import { useQuery, useQueryClient } from 'react-query';
import { Box, Button, CircularProgress, Dialog, DialogActions, DialogContent, DialogTitle, Snackbar } from '@mui/material';
import { Add, Edit, DeleteOutlined, Save, Close } from '@mui/icons-material';
import {
  GridRowModes,
  DataGrid,
  GridToolbarContainer,
  GridActionsCellItem,
} from '@mui/x-data-grid';

import { getBooks } from './book-api';
import { useMutateBooks } from './useMutateBooks';

function EditToolbar({ onAdd }) {
  return (
    <GridToolbarContainer>
      <Button color="primary" startIcon={<Add />} onClick={onAdd}>
        Add Book
      </Button>
    </GridToolbarContainer>
  );
}

const handlePreventDefault = (_params, event) => {
  event.defaultMuiPrevented = true;
};

export default function BookGrid() {
  const box = useRef();
  const [height, setHeight] = useState(500);
  const queryClient = useQueryClient();
  const [page, setPage] = useState(0);
  const setBooks = (books) => queryClient.setQueryData('books', books);
  const [rowModesModel, setRowModesModel] = useState({});
  const {data, isLoading} = useQuery('books', getBooks, { onSuccess: (collection) => {
    setRowModesModel(Object.fromEntries(collection.map((row) => [row.book_id, { mode: editing === row.book_id ? GridRowModes.Edit : GridRowModes.View }])));
  }});
  const [editing, setEditing] = useState(undefined);
  const [pendingDelete, setPendingDelete] = useState();

  const {mutate, isError, isSuccess, reset} = useMutateBooks();

  useLayoutEffect(() => {
    const handleResize = () => {
      if (box.current) {
        setHeight(box.current.clientHeight);
      }
    }

    handleResize();

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    }
  }, [isLoading]);

  const mutateCreate = book => mutate({action: 'create', book});
  const mutateUpdate = book => mutate({action: 'update', book});
  const mutateDelete = book => mutate({action: 'delete', book});

  const handleEditClick = (id) => () => {
    setEditing(id);
    setRowModesModel({...editing, [id]: { mode: GridRowModes.Edit }});
  };

  const handleSaveClick = (id) => () => {
    setEditing(undefined);
    setRowModesModel({...editing, [id]: { mode: GridRowModes.View }});
  };

  const handleDeleteClick = (id) => () => {
    setPendingDelete(data.find(book => book.book_id === id));
  };

  const handleCancelClick = (id) => () => {
    setEditing(undefined);
    // ignoreModifications true will cause processRowUpdate not to be called
    setRowModesModel({...editing, [id]: { mode: GridRowModes.View, ignoreModifications: true }});

    if (data.some((row) => row.isNew)) {
      setBooks(data.filter((row) => row.book_id !== id));
    }
  };

  const handleAdd = () => {
    // TODO Get highest ID and increment by 1
    // TODO this should be done by the backend actually, the problem is just that datagrid needs a unique id
    const newBook = { book_id: 9999, authors: '', average_rating: '', isbn: '', language_code: 'eng', original_publication_year: '', title: '', isNew: true };
    setEditing(newBook.book_id);
    setBooks([newBook, ...data]);
    setPage(0);
  }

  const processRowUpdate = (newBook, _oldBook) => {
    const {isNew, ...book} = newBook;

    isNew ? mutateCreate(book) : mutateUpdate(book);

    return newBook;
  };

  const columns = [
    {
      field: 'book_id',
      headerName: 'ID',
      editable: true,
      flex: 1,
    }, {
      field: 'title',
      headerName: 'Title',
      editable: true,
      flex: 1,
    }, {
      field: 'authors',
      headerName: 'Authors',
      editable: true,
      flex: 1,
    }, {
      field: 'isbn',
      headerName: 'ISBN',
      editable: true,
      valueSetter: ({row, value}) => ({...row, isbn: +value}),
      flex: 1,
    }, {
      field: 'original_publication_year',
      headerName: 'Original Publication Year',
      editable: true,
      valueSetter: ({row, value}) => ({...row, original_publication_year: +value}),
      flex: 1,
    }, {
      field: 'language_code',
      headerName: 'Language Code',
      editable: true,
      flex: 1,
    }, {
      field: 'average_rating',
      headerName: 'Average Rating',
      editable: true,
      valueSetter: ({row, value}) => ({...row, average_rating: +value}),
      flex: 1,
    }, {
      field: 'actions',
      type: 'actions',
      headerName: 'Actions',
      width: 100,
      cellClassName: 'actions',
      getActions: ({ id }) => {
        if (editing === id) {
          return [
            <GridActionsCellItem
              icon={<Save />}
              label="Save"
              onClick={handleSaveClick(id)}
            />,
            <GridActionsCellItem
              icon={<Close />}
              label="Cancel"
              className="textPrimary"
              onClick={handleCancelClick(id)}
              color="inherit"
            />,
          ];
        }

        return [
          <GridActionsCellItem
            disabled={!!editing}
            icon={<Edit />}
            label="Edit"
            className="textPrimary"
            onClick={handleEditClick(id)}
            color="inherit"
          />,
          <GridActionsCellItem
            disabled={!!editing}
            icon={<DeleteOutlined />}
            label="Delete"
            onClick={handleDeleteClick(id)}
            color="inherit"
          />,
        ];
      },
      flex: 1,
    },
  ];

  if (isLoading) return (<Box sx={{ display: 'flex', justifyContent: 'center' }}>
  <CircularProgress />
</Box>);

  return (
    <>
      <Dialog
        open={!!pendingDelete}
        onClose={() => setPendingDelete(undefined)}
      >
        <DialogTitle>Confirm Delete</DialogTitle>
        <DialogContent>
          Are you sure you want to delete {pendingDelete?.title} ({pendingDelete?.book_id})?
        </DialogContent>
        <DialogActions>
          <Button variant="text" onClick={() => setPendingDelete(undefined)}>
            Cancel
          </Button>
          <Button variant="contained" onClick={() => {mutateDelete(pendingDelete);setPendingDelete(undefined)}}>
            Confirm
          </Button>
        </DialogActions>
      </Dialog>
      <Snackbar
        open={isError}
        message="Error"
        onClose={reset}
        autoHideDuration={5000}
        action={<Button color="secondary" size="small" onClick={reset}>Dismiss</Button>}
      />
      <Snackbar
        open={isSuccess}
        onClose={reset}
        autoHideDuration={5000}
        message="Book saved"
      />
      <Box
        ref={box}
        sx={{
          flex: 1,
          height,
        }}
      >
        <DataGrid
          onRowEditCommit={(id, event) => console.log('onRowEditCommit',id,event)}
          sx={{border: 0}}
          page={page}
          onPageChange={(newPage) => setPage(newPage)}
          getRowId={(data) => data.book_id}
          rows={data}
          columns={columns}
          editMode="row"
          rowModesModel={rowModesModel}
          onRowModesModelChange={(newModel) => setRowModesModel(newModel)}
          onRowEditStart={handlePreventDefault}
          onRowEditStop={handlePreventDefault}
          processRowUpdate={processRowUpdate}
          components={{
            Toolbar: EditToolbar,
          }}
          componentsProps={{
            toolbar: { onAdd: handleAdd },
          }}
          experimentalFeatures={{ newEditingApi: true }}
        />
      </Box>
    </>
  );
}
