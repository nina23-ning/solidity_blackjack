//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
id: address of player
privatecard: private card dealt to the player
publiccards: public card dealt to the player
lastTime: timestamp of when the player last made a move;
inGame: if the player is still ingame;
*/
struct Player{
    address id;
    uint privateCard;
    uint[] publicCards;
    uint lastTime;
    bool inGame;
}

/*
players: the two players in the game
cards: a list of cards, "" if taken

*/
contract Blackjack {
    Player[] private players;
    string[52] internal cards;
    bool public game = false;
    string public alert = '';
    string public result = '';
    event log(string t);
    event log(uint v);
    /*random: returns a random number between 0 and 51*/
    function random(address seed) private view returns(uint){
        uint num = block.number+uint(block.difficulty)-uint(uint160(seed))%block.number;
        return (num)%52;
    }
    /*equal: returns whether two strings are equal*/
    function equal(string storage x, string memory y) private view returns(bool){
        if (bytes(x).length != bytes(y).length){
            return false;
        }
        return keccak256(abi.encodePacked(x)) == keccak256(abi.encodePacked(y));
    }
    /*getCard: returns card value*/
    function getCard(uint x) private pure returns (uint){
        if (x > 36){
            return 10;
        }
        return x/4+1;
    }
    function getCValue(address id) private view returns (uint){
        if (players.length < 2){
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
        uint v = getCard(players[p].privateCard);
        for (uint i = 0; i < players[p].publicCards.length; i++){
            v += getCard(players[p].publicCards[i]);
        }
        return v;
    }
    /*validateGame: returns state of game*/
    function validateGame() private returns (bool){
        //if game is not in session, return false
        if (!game) return false;
        //if it has been 10 seconds since the player last moved, the player is out
        if (block.timestamp - players[0].lastTime > 10){
            players[0].inGame = false;
        }
        if (block.timestamp - players[1].lastTime > 10){
            players[1].inGame = false;
        }
        //if the player value totals over 21, the player is out 
        if (players[0].inGame && getCValue(players[0].id) > 21){
            players[0].inGame = false;
        }
        if (players[1].inGame && getCValue(players[1].id) > 21){
            players[1].inGame = false;
        }
        //if both players are not in game, find the winner and return false
        if (!players[0].inGame && !players[1].inGame){
            uint v1 = getCValue(players[0].id);
            uint v2 = getCValue(players[1].id);
            game = false;
            if ((v1 > 21) && (v2 > 21)){
                result = "No player has won";
            }
            else if (v1 > 21){
                result = "Player 2 has won";
            }
            else if (v2 > 21){
                result = "Player 1 has won";
            }
            else if (v1 == v2){
                result = "The players have tied";
            }
            else{
                result = ((21-v1)<(21-v2))? "Player 1 has won":"Player 2 has won";
            }
            emit log(result);
        }
        return game;
    }
    /*join: adds a player if game not in session*/
    function addPlayer(address id) private returns (bool){
        if (game){
            return false;
        }
        if (players.length > 1){
            alert = "Maximum players reached.";
            return false;
        }
        if ((players.length == 1) && (players[0].id == id)){
            alert = "Same player cannot be in the same game.";
            return false;
        }
        uint[] memory empty;
        players.push(Player(id,0,empty,block.timestamp,false));
        return true;
    }
    /*refreshCards: resets the cards*/
    function refreshCards() private{
        cards = [
            ("Ace of Spades"),("Ace of Clubs"),("Ace of Diamonds"),("Ace of Hearts"),
            ("2 of Spades"),("2 of Clubs"),("2 of Diamonds"),("2 of Hearts"),
            ("3 of Spades"),("3 of Clubs"),("3 of Diamonds"),("3 of Hearts"),
            ("4 of Spades"),("4 of Clubs"),("4 of Diamonds"),("4 of Hearts"),
            ("5 of Spades"),("5 of Clubs"),("5 of Diamonds"),("5 of Hearts"),
            ("6 of Spades"),("6 of Clubs"),("6 of Diamonds"),("6 of Hearts"),
            ("7 of Spades"),("7 of Clubs"),("7 of Diamonds"),("7 of Hearts"),
            ("8 of Spades"),("8 of Clubs"),("8 of Diamonds"),("8 of Hearts"),
            ("9 of Spades"),("9 of Clubs"),("9 of Diamonds"),("9 of Hearts"),
            ("10 of Spades"),("10 of Clubs"),("10 of Diamonds"),("10 of Hearts"),
            ("Jack of Spades"),("Jack of Clubs"),("Jack of Diamonds"),("Jack of Hearts"),
            ("Queen of Spades"),("Queen of Clubs"),("Queen of Diamonds"),("Queen of Hearts"),
            ("King of Spades"),("King of Clubs"),("King of Diamonds"),("King of Hearts")
        ];
    }
    /*dealPrivate: deals a private card to each player*/
    function dealPrivate() private{
        if (!game){
            return;
        }
        uint r1 = random(players[0].id);
        uint r2 = random(players[1].id);
        while (r2 == r1){
            r2 = (r2+random(players[1].id)+1)%52;
        }
        players[0].privateCard = r1;
        players[1].privateCard = r2;
        cards[r1] = "";
        cards[r2] = "";
    }
    /*dealPublic: deals a public card to player*/
    function dealPublic(address id) private{
        uint p = 0;
        if (!game){
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
        if (!validateGame()){
            return;
        }
        if (!players[p].inGame){
            return;
        }
        uint r = random(id);
        while (equal(cards[r],"")){
            r = (r+random(id)+1)%52;
        }
        cards[r] = "";
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
        if ((players.length == 2) && !(game)){
            game = true;
            players[0].inGame = true;
            players[1].inGame = true;
            players[0].privateCard = 0;
            players[1].privateCard = 0;
            uint[] memory empty;
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
    function gameOutcome() external returns (string memory){
        validateGame();
        emit log(this.result());
        return this.result();
    }
    /*myScore: returns the sender's score*/
    function myScore() external view returns(uint){
        return getCValue(msg.sender);
    }
    /*myStatus: returns whether player is in game and alive*/
    function myStatus() external view returns(bool){
        if (!game) return false;
        if (msg.sender == players[0].id) return players[0].inGame;
        if (msg.sender == players[1].id) return players[1].inGame;
        return false;
    }
}