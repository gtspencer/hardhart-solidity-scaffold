// App.js
import React from 'react';
import HomePage from './HomePage'; // Your main component
import DetailsPage from './DetailsPage'; // New component for details page
import {
    BrowserRouter, Routes,
    Route, Link
} from 'react-router-dom'

function App() {
  return (
    <BrowserRouter>
            <Routes>
                <Route path='/' element={<HomePage />}>
                </Route>
                <Route path='/details'
                    element={<DetailsPage />}>
                </Route>
            </Routes>
        </BrowserRouter>


    // <div className="App">
    //   <HomePage />
    // </div>
  );
}

export default App;
