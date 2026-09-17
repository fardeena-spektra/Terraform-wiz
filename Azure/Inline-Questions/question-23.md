## MetaData
Question Type : Single Choice
Module : M5 - Python

## Question
3. A script raises a UnicodeDecodeError when logging message content read from a broker. What is the most likely cause?

## Options
Option 1 : The script is assuming a text encoding when decoding raw bytes, and the actual message content doesn't match that assumption

Option 2 : The broker has corrupted the message, and the decode error reflects damaged bytes arriving over the network

Option 3 : Python cannot print any non-English characters, so any message with such content triggers a decode failure

Option 4 : The script needs a newer version of Python to log text, since older versions lack Unicode support entirely

## Answers
Option 1 : 1

## Correct Answer Feedback
Correct. This is a classic bytes-vs-text handling issue — the fix is to decode with the correct encoding (or handle decode errors explicitly), not to assume the message itself is corrupted.

## Number of Retries
1