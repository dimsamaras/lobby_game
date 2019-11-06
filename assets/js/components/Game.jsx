// assets/js/Root.tsx

import * as React from 'react'
import Ball from './Ball';
import { number } from 'prop-types';

const Game = ({user_id, lobbyState}) => {
    return (
        lobbyState.map((item, key) => 
            <Ball own={item.user_id === user_id} 
                color={item.color} type={key} counter={item.points} key={key}/>
        )
    )
}

export default Game;