## Pong Game Implementation on Basys 3 FPGA

This repository contains the hardware implementation of a two player pong game. Two paddles are moved up and down using the push buttons. The triangular ball
moves in random direction and the players tries to hit the ball with their ball. Once the ball is missed, the opponent gets a point and his scoreboard is increased. 
The scoreboard is increased after each miss. Once a player reaches a point of 9, the game is over. The pong game can be reset with the reset_im input button.
