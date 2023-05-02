//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
id: address of player
publiccards: public card dealt to the player
privatecard: private card dealt to the player
lastTime: timestamp of when the player last made a move;
inGame: if the player is still ingame;
*/
struct Player{
    address id;
    uint[] publicCards;
    uint privateCard;
    uint lastTime;
    bool inGame;
}

/*
players: the two players in the game
cards: a list of cards, "" if taken

*/
contract Blackjack {
    Player[] private players;
    address public result;
    uint[13] internal cards;
    uint public alert = 0;
    uint public game = 0;
    /*getCard: returns card value*/
    function getCard(uint x) private pure returns (uint){
        return x>9? 10:(x+1);
    }
    /*random: returns a random number between 0 and 12*/
    function random(address seed) private view returns(uint){
        uint num = block.number+uint(block.difficulty)-uint(uint160(seed))%block.number;
        return (num)%13;
    }
    /*getPublicValue: returns public value*/
    function getPublicValue(address id) private view returns (uint){
        if ((players.length < 2) || (game == 0)){
            return 0;
        }
        uint p = 2;
        if (id == players[0].id){
            p = 0;
        }
        else if (id == players[1].id){
            p = 1;
        }
        else{
            return 0;
        }
        uint v = 0;
        for (uint i = 0; i < players[p].publicCards.length; i++){
            v += getCard(players[p].publicCards[i]);
        }
        return v;
    }
    /*getHandValue: returns hand value*/
    function getHandValue(address id) private view returns (uint){
        if ((players.length < 2) || (game == 0)){
            return 0;
        }
        uint p = 2;
        if (id == players[0].id){
            p = 0;
        }
        else if (id == players[1].id){
            p = 1;
        }
        else{
            return 0;
        }
        return getCard(players[p].privateCard) + getPublicValue(players[p].id);
    }
    /*validateGame: returns state of game*/
    function validateGame() private returns (bool){
        //if game is not in session, return false
        if (game != 1) return false;
        //if it has been 15 seconds
        //if card value greater than 21
        if ((players[0].inGame) &&
            ((block.timestamp - players[0].lastTime > 15) ||
            getCard(players[0].privateCard) + getPublicValue(players[0].id) > 21)){
            players[0].inGame = false;
        }
        if ((players[1].inGame) &&
            ((block.timestamp - players[1].lastTime > 15) || 
            getCard(players[1].privateCard) + getPublicValue(players[1].id) > 21)){
            players[1].inGame = false;
        }
        //if both players are not in game, find the winner and return false
        if (!players[0].inGame && !players[1].inGame){
            uint v1 = getCard(players[0].privateCard) + getPublicValue(players[0].id);
            uint v2 = getCard(players[1].privateCard) + getPublicValue(players[1].id);
            game = 2;
            if ((v1 == v2) || ((v1 > 21) && (v2 > 21))){
            }
            else if (v1 > 21){
                result = players[1].id;
            }
            else if (v2 > 21){
                result = players[0].id;
            }
            else{
                result = ((21-v1)<(21-v2))? players[0].id:players[1].id;
            }
        }
        return game == 1;
    }
    /*join: adds a player if game not in session*/
    function addPlayer(address id) private returns (bool){
        if (game == 1){
            return false;
        }
        if (players.length > 1){
            alert = 1; //Maximum
            return false;
        }
        if ((players.length == 1) && (players[0].id == id)){
            alert = 2; //Same player
            return false;
        }
        uint[] memory empty;
        players.push(Player(id,empty,0,block.timestamp,false));
        return true;
    }
    /*refreshCards: resets the cards*/
    function refreshCards() private{
        //four of each type
        cards = [
            4,4,4,4,4,4,4,4,4,4,4,4,4
        ];
    }
    /*dealPrivate: deals a private card to each player*/
    function dealPrivate() private{
        if (game != 1){
            return;
        }
        uint r1 = random(players[0].id);
        uint r2 = random(players[1].id);
        while (r2 == r1){
            r2 = (r2+random(players[1].id)+1)%13;
        }
        players[0].privateCard = r1;
        players[1].privateCard = r2;
        cards[r1] -= 1;
        cards[r2] -= 1;
    }
    /*dealPublic: deals a public card to player*/
    function dealPublic(address id) private{
        uint p = 2;
        if (game != 1){
            return;
        }
        if (id == players[0].id){
            p = 0;
        }
        else if (id == players[1].id){
            p = 1;
        }
        else{
            return;
        }
        if (!validateGame() || !players[p].inGame){
            return;
        }
        uint r = random(id);
        while (cards[r] < 1){
            r = (r+random(id)+1)%52;
        }
        cards[r] -= 1;
        players[p].publicCards.push(r);
        players[p].lastTime = block.timestamp;
    }
    /*getPlayers: returns list of players*/
    function getPlayers() external view returns (address[2] memory){
        address[2] memory p;
        if (players.length == 0){
            return p;
        }
        if (players.length == 1){
            p[0] = players[0].id;
            return p;
        }
        p = [players[0].id,players[1].id];
        return p;
    }
    /*join: lets someone join the game*/
    function join() external{
        addPlayer(msg.sender);
    }
    /*startGame: starts the game*/
    function startGame() external{
        if ((players.length == 2) && (game != 1)){
            game = 1;
            players[0].inGame = true;
            players[1].inGame = true;
            players[0].privateCard = 0;
            players[1].privateCard = 0;
            uint16[] memory empty;
            players[0].publicCards = empty;
            players[1].publicCards = empty;
            players[0].lastTime = block.timestamp;
            players[1].lastTime = block.timestamp;
            refreshCards();
            dealPrivate();
        }
    }
    /*drawCard: draws a card*/
    function drawCard() external{
        dealPublic(msg.sender);
    }
    /*gameOutcome: logs and returns the outcome*/
    function gameOutcome() external returns (address){
        validateGame();
        return result;
    }
    /*myScore: returns the sender's score*/
    function myScore() external view returns(uint){
        return getHandValue(msg.sender);
    }
    /*myStatus: returns whether player is in game and alive*/
    function myStatus() external view returns(bool){
        if (game != 1) return false;
        if (msg.sender == players[0].id) return players[0].inGame;
        if (msg.sender == players[1].id) return players[1].inGame;
        return false;
    }
    /*publicCards: returns both scores if game in state*/
    function publicCards() external view returns(uint[2] memory){
        uint[2] memory scores;
        if (game != 0){
            scores[0] = getPublicValue(players[0].id);
            scores[1] = getPublicValue(players[1].id);
        }
        return scores;
    }
    /*finalScore: returns both scores if game has ended*/
    function finalScore() external view returns(uint[2] memory){
        uint[2] memory scores;
        if (game == 2){
            scores[0] = getHandValue(players[0].id);
            scores[1] = getHandValue(players[1].id);
        }
        return scores;
    }
}
