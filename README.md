## CSCI-4240 Project
### Nina Ning
#### Description
This project uses Solidity to write a smart contract on the Ethereum blockchain such that two addresses can play Blackjack with one another. The traits of the blockchain are used to make the game as fair and secure as possible. The `Blackjack.sol` file contains the contract code, and this README file contains directions that demonstrate how to run an example of using the contract to play a game of Blackjack..
#### Compilation
The project was compiled using the Remix IDE. In order to run the project, follow the following steps:
1) Head to [remix.ethereum.org].  
2) Select upload files.
3) Upload the `Blackjack.sol` file.
4) Head to the third tab "Solidity compiler". Click "Compile Blackjack.sol".
5) Head to the fourth tab "Deply and run transactions". Select an account for deployment and click "Deploy".
6) Scroll to the bottom and open BLACKJACK under Deployed Contracts.
7) Now you can play the game.
##### Game Overview
To play the game, first select one account and select `join`.
Then, scroll to the top and select a different account (do not press Deploy again), scroll back down, and select `join`.
Select `startGame`. At this point, private cards will be dealt to each of the two players.
Select `drawCard` to draw a card for the given account. Select `myScore` to see what your current score is.
After you are comfortable with your selection, wait for 30 seconds. Select `gameOutcome` and `result`. This will display the overall winner.
##### Code Specifics
Do notice there are a couple of other functions and buttons as well. A few things to note:
The following are variables you can look at. For the variables `game` and `myStatus`, you must first select `gameOutcome` to update the status of the game, because the contract does not do this automatically in view permission functions.
`alert` will show if there are any alerts, such as if the same player joined twice.
`game` will show if the game is currently active.
`getPlayers` will show the current playerlist.
`myScore` shows the score of the message sender. If the sender is not in the game, this will return a value of 0.
`myStatus` shows whether the player is currently "alive" and in the game.
`result` shows the result of the game.
#### Special Consideration
The smart contract used different traits of the blockchain in order to be able to implement the game. Often, in casinos and such, it is questionable whether the card dealing is truly random and whether the game is actually fair. This is mediated using a few traits of the blockchain: close-to-true randomness, decentralization, and block timestamps.  
1) The Ethereum blockchain already has some degree of randomness in the block traits. As such, this is a good source of randomness to pull random cards for two players.  
2) The decentralization helps verify the results of the game and that it was fair. Because the results and details of the game are stored in the blockchain transactions, a wide audience can verify that the game was valid simply by continuing to mine Ethereum.  
3) Each block in the Ethereum blockchain includes a timestamp. This means that we have a relatively accurate source of information to determine how much time passed between not only when a game started and when it ended, but also when each player submitted their transaction to be dealt a card. This is useful to determine when the game times out.
[//]: #(List)
Of course, there were also some difficulties encountered on the blockchain. For example, because all information is present in the block, players can also view each other's "private" cards that are normally dealt face down and only visible to the player to whom the card was dealt, although this is not a supported public function within the smart contract itself. This is also because of the nature of blockchain; how data is stored in the blocks and viewable by everyone. This problem remains to be solved. One way of addressing this problem is to move the private information offchain, but that could be against the purpose of the project in making the smart contract supervise the entire game.
Due to the nature of smart contracts and how they function on the blockchain, a couple of other vulnerabilities exist. To take measures against this, certain behavior was used in the smart contract. Specifically, in general, it is a bad idea to use blockchain traits such as the block hashes as a source of randomness, because miners can select blocks to toss out to gain an edge here. However, taking into account that the game runs for very little time, and that there is a 10 second time limit on inactivity (based on block timestamps, which miners can also alter but only generally in the minutes range), using the block number and block difficulty may suffice here. 
