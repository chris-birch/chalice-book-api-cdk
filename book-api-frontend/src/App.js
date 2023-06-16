import { Amplify } from 'aws-amplify';
import { withAuthenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import {
  QueryClient,
  QueryClientProvider,
} from 'react-query'
import { AppBar, Button, Toolbar, Typography } from '@mui/material';

import awsExports from './aws-exports';

import BookGrid from './BookGrid';

Amplify.configure({awsExports,
  Auth: {
    identityPoolId: 'eu-west-2:a74e58bf-ba1a-4fdb-b205-457f627970ad', // REQUIRED - Amazon Cognito Identity Pool ID
    region: 'eu-west-2', // REQUIRED - Amazon Cognito Region
    userPoolId: 'eu-west-2_ZH1AyCQvw', // OPTIONAL - Amazon Cognito User Pool ID
    userPoolWebClientId: '7l5scc3in5gvress2g1nouclq7', // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
    },

  API: {
    endpoints: [
        {
          name: "ChaliceAPI",
          endpoint: "https://7knyhecr3f.execute-api.eu-west-2.amazonaws.com/api",
          region: "eu-west-2"
        }
    ]
  }
});

const queryClient = new QueryClient()

function App({ signOut }) {
  return (
    <QueryClientProvider client={queryClient}>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Books
          </Typography>
          <Button color="inherit" onClick={signOut}>Sign out</Button>
        </Toolbar>
      </AppBar>
      <BookGrid />
    </QueryClientProvider>
  );
}

export default withAuthenticator(App);
