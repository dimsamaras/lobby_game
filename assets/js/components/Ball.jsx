import React from 'react';

import TypesToIcons from '../constants';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'

const Ball = ({own, color, type, counter}) => (
    <>
        <FontAwesomeIcon className="ball" icon={TypesToIcons[type]} color={color} size={own ? "5x" : "1x"}/  >
        <p>{counter}</p>
        {
            counter == 5 &&
            <p>Not a winner... :(</p>
        }
    </>
)

export default Ball;