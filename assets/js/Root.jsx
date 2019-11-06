// assets/js/Root.tsx

import * as React from 'react'
import socket from "./socket"
import Game from './components/Game';

export default class Root extends React.Component {
   constructor(props) {
    super(props);
    this.state = {
      user_id: null,
      lobbyState: [

      ],
      lobby: null,
      lobby_id: null,
      timer: 0,
      winner: null,
    };

    
    // this.handleClick.bind(this);
  }

  componentDidMount() {
    let channel = socket.channel("lobby:game", {})
    channel.join()
      .receive("ok", resp => {

        let lobby_id = resp.lobby_id;
        

        let lobby = socket.channel(`lobby:${lobby_id}`)
        lobby.join()
        .receive("ok", resp => {
          console.log(`Connected on lobby ${lobby_id}`)
          this.setState({
            user_id: resp.user_id,
          })
        })

        lobby.on("new_state", payload => {
          this.setState({
            lobbyState: payload.users,
          })
        })

        lobby.on("timer", payload => {
          this.setState({
            timer: payload.timer,
          })
        })

        lobby.on("new_winner", payload => {
          this.setState({
            winner: payload.winner,
          })
        })

        this.setState({
          lobby_id: resp.lobby_id,
          user_id: resp.user_id,
          lobby: lobby
        })
      })
      .receive("error", resp => { console.log("Unable to join", resp) })
  }

  handleClick(e) {
    e.preventDefault();
    this.state.lobby.push("change_color", "")
  }

  render() {
    return (
      <>
        <Game lobbyState={this.state.lobbyState} user_id={this.state.user_id}/>
        <div><button onClick={(e) => this.handleClick(e)} >Change color</button></div>
        <div>{this.state.timer}</div>
        {
          this.state.winner !== null && this.state.winner == this.state.user_id &&
            <h3>You won!!!</h3>
        }

        {
          this.state.winner !== null && this.state.winner != this.state.user_id &&
            <h3>You lost... Try again...</h3>
        }
      </>
    )
  }
}