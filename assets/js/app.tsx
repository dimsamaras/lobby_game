// assets/js/app.tsx

import '../css/app.css'

import 'phoenix_html'

import * as React from 'react'
import * as ReactDOM from 'react-dom'
import Root from './Root'


import { library } from '@fortawesome/fontawesome-svg-core'
import { faVolleyballBall, faBowlingBall, faBasketballBall, faBaseballBall, faTableTennis } from '@fortawesome/free-solid-svg-icons'

library.add(faVolleyballBall, faBaseballBall, faBowlingBall, faBasketballBall, faTableTennis)

// This code starts up the React app when it runs in a browser. It sets up the routing
// configuration and injects the app into a DOM element.
ReactDOM.render(<Root />, document.getElementById('react-app'))

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
