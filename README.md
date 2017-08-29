# MPCS 51033 Final Project

This project uses three different services.

## Google app engine - Provides backend server for storing high scores 
I choose Google App Engine for this because filering and sorting is much easier

## Firebase - Stores user game data and level data
I use firebase to store level data, which allows the developer to add new level using the game's Developer's app to design new levels, 
upload it to firebase, and when the user launches the app, the game app will automatically download all new levels. No updates neccessary! 
The level data of my game are stored as an 2D array, which is hard to represent in data structure using most backend solutions, but firebase is perfect for it. Persisting user data is also the easiest using firebase because I store list of highscores and game status. The user can also transfer their
current game progress to different devices using transfer code. 

## CloudKit - 
In my developer's app, I added a textfield that allows the developer to upload a message to CloudKit. All game users have a silent subscription to it. When the user receives the message, the app sends a local notification to the user showing the developer's message.

# The apps

# Pastry Dream

This repository contains two xcode projects. 

- CatJumpGame (The main game app, has "Pastry Dream" as its display name) 

- CatGameDeveloper (The app for the developer to interact with the main game app)

# CatJumpGame Main Features

- Shows a game tutorial on first launch
- Has five built in levels.
- Each level unlocked by successfully completing the previous level
- Upload High Scores to Google App Engine (the server code was uploaded in the Backend Final Project Repository)
- Display 4 of the Highest scores for each level
- Syncs the user's game data to firebase
- Allow the user to transfer game progress between devices
- Autonatically checks for updated levels and donwload level data
- Receive notifications messages sent from the developer
- Pause/ Archieve games when game was interrupted 
- Allow the user to turn on/off background music

# CatGameDevelopers

- A very sparse app for the developer to interact with the main app
- Allows the developer to send messages to user
- Developers can design new level and push the update to the server





