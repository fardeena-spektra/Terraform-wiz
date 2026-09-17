## MetaData
Question Type : Single Choice
Module : M1 - IBM MQ

## Question
4. A channel between two queue managers shows status RETRYING. What does this most likely mean?

## Options
Option 1 : The channel has been permanently disabled and requires manual re-enabling before any further attempts

Option 2 : Messages on this channel have been deleted and will need to be re-sent by the producer

Option 3 : The channel is repeatedly attempting to reconnect, usually due to a network issue or the partner queue manager being unavailable

Option 4 : The channel definition needs to be recreated from scratch, since retrying status indicates a corrupted configuration

## Answers
Option 3 : 2

## Correct Answer Feedback
Correct. RETRYING means the channel is actively trying to re-establish a connection it lost — check network connectivity and the partner queue manager's availability before assuming the channel definition itself is broken.

## Number of Retries
1