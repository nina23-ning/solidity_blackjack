## CSCI-4240 Project
### Nina Ning
#### Description
This project uses Solidity to write a smart contract on the Ethereum blockchain such that two addresses can play Blackjack with one another. The traits of the blockchain are used to make the game as fair and secure as possible. The `Blackjack.sol` file contains the contract code, and this README file contains directions that demonstrate how to run an example of using the contract to play a game of Blackjack.  
#### Compilation
The project was compiled using the Remix IDE. In order to run the project, follow the following steps:  
1) Head to [Remix IDE](remix.ethereum.org).  
2) Select upload files.
3) Upload the `Blackjack.sol` file.
4) Head to the third tab "Solidity compiler". Click "Compile Blackjack.sol".
5) Head to the fourth tab "Deploy and run transactions". Select an account for deployment and click "Deploy".
6) Scroll to the bottom and open BLACKJACK under Deployed Contracts.
7) Now you can play the game.
##### Game Overview
To play the game, first select one account and select `join`.  
Then, scroll to the top and select a different account (do not press Deploy again), scroll back down, and select `join`. 
To check that both players are in game, select `getPlayers`. It should show two nonzero addresses. If it does not, then there are not enough players.  
Select `startGame`. At this point, private cards will be dealt to each of the two players.  
Select `drawCard` to draw a card for the given account. Select `myScore` to see what your current score is. Select `publicCards` to see what cards both players have face up.  
After you are comfortable with your selection, wait for 10 seconds. Select `gameOutcome` and `result`. This will display the address of the overall winner. To view the hand values, select `finalScore`.  
##### Code Specifics
Do notice there are a couple of other functions and buttons as well. A few things to note:  
The following are variables you can look at. For the variables `finalScore` `game` and `myStatus`, you must first select `gameOutcome` to update the status of the game, because the contract does not do this automatically in view permission functions.  
`alert` will show if there are any alerts, such as if the same player joined twice. 0 means no alerts, 1 means the player list is full, and 2 means that the same player has attempted to join twice.   
`finalScore` will show the hand values of both players only if the game has concluded.  
`game` will show if the game is currently active. 0 means the game has not started, 1 means the game has started, and 2 means the game has concluded.  
`getPlayers` will show the current playerlist.  
`myScore` shows the score of the message sender. If the sender is not in the game, this will return a value of 0.  
`myStatus` shows whether the player is currently "alive" and participating in an ongoing game.  
`result` shows the address of the winner. If there is a tie, or the game has not ended yet, it will be zero.  
#### Special Consideration
The smart contract used different traits of the blockchain in order to be able to implement the game. Often, in casinos and such, it is questionable whether the card dealing is truly random and whether the game is actually fair. This is mediated using a few traits of the blockchain.  

- The Ethereum blockchain already has some degree of randomness in the block traits. As such, this is a good source of randomness to pull random cards for two players.  
- The decentralization helps verify the results of the game and that it was fair. Because the results and details of the game are stored in the blockchain transactions, a wide audience can verify that the game was valid simply by continuing to mine Ethereum.  
- Each block in the Ethereum blockchain includes a timestamp. This means that we have a relatively accurate source of information to determine how much time passed between not only when a game started and when it ended, but also when each player submitted their transaction to be dealt a card. This is useful to determine when a player times out.  
#### Security  
There were also some difficulties encountered on implementing the game. For example, because all information is present in the block, players can also technically view each other's "private" cards that are normally dealt face down and only visible to the player to whom the card was dealt, although this is not supported within the smart contract itself. Although this does not offer the player a breaking edge, it changes the nature of the game.
This issue is due to how data is stored in the blocks and viewable by everyone. This problem remains to be solved. One way of addressing the problem is to move the private information offchain, but that could be against the purpose of the project in making the smart contract supervise the entire game. Despite the issue, security on chain was still implemented to the best possible extent. For example, functions that address the private card were kept private and functions that revealed the private card value were not called in external functions.
Due to the nature of smart contracts and how they function on the blockchain, a couple of other vulnerabilities exist. To take measures against this, certain behavior was used in the smart contract. Specifically, in general, it is a bad idea to use blockchain traits such as the block hashes as a source of randomness, because miners can select blocks to toss out to gain an edge here. However, taking into account that the game runs for very little time, and that there is a 15 second time limit on inactivity (based on block timestamps, which miners can also alter but only generally in the minutes range), using the block number and block difficulty may suffice here.  
#### Gas Cost  
Some changes were made to the functions as well due to gas cost. The intent is to make the gas cost finite and as low as possible, so that there is an upper limit to gas consumed and less gas is consumed when playing the game. In order to do this, extraneous variables and especially strings were removed. In previous iterations, strings were present, but because operations with strings often take more gas and storage, and string format may not be necessary to convey the info, I opted to replace them with numbers. For example, I previously had the card array as an array of 52 strings. Later, though, I noticed that never once did I actually display the card to the user, and that in the actual game, the only thing that really mattered was the score. One could make an argument for knowing the value of the card, but not so much the suite. As such, I changed it to an array of 13 unsigned ints. This reduced the gas cost substantially because I no longer had to use gas intensive operations to check if two strings were equal. Rather, I compard whether the number of cards was less than 1.  
In addition to this change, I also changed the ordering of variables and functions such that the structs are more tightly packed and so important function calls may cost less. In the functions themselves, I also added more short-circuiting and ternary statements, which means less operations are done, so a smaller gas cost is produced.
