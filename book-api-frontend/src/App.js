import { Amplify, API } from 'aws-amplify';

import { withAuthenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';
import {


  QueryClient,

  QueryClientProvider,

} from 'react-query'



import Books from './Books';
import awsExports from './aws-exports';
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

// API.get(apiName, path, myInit)
//   .then((response) => {
//     console.log(response)
//   })
//   .catch((error) => {
//     console.log(error.response);
//   });



// Create a client

const queryClient = new QueryClient()

function App({ signOut, user }) {
  return (
  <QueryClientProvider client={queryClient}>
      <h1>Hello {user.username}</h1>
      <button onClick={signOut}>Sign out</button>

    <Books api={API}/>
  </QueryClientProvider>
  );
}

export default withAuthenticator(App);
