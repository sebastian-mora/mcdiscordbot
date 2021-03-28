# mcdiscordbot

Allow starting and stopping of Minecraft server instances hosted in AWS via a
Discord bot interface. 

[![Alt text](./diagram.jpg)]

## Deploying Bot

This repo is not a plug-and-play solution, there a few elements which have not yet be configured with Terraform to automate deployment. In the future, I would like to have this process completely automated. 

The first feature is the bot client. This is not included in the repo but only interfaces with the API deployed here. I will leave the implementation of the API client for you. 

The servers need to be configured and deployed with the following tags Name, Description, Minecraft: true.

SNS and cloud watch need to be created as well.

Long story short this is in a state to be auto deployed, rather use it as a reference on how to implement. 

## Usage

**!mc list**

List all available server instances along with their associated metadata like name etc.

**!mc status**

List all running Minecraft servers and returns metadata about game server and player count.

**!mc start {name}**

Start the specified Minecraft server. After a few started an alert will be sent in the chat with the connection information.

**!mc stop {name}**

Stop the specified Minecraft server. 


After a set time (default: 30mins) any running servers with a player account of 0 will be shutoff.

## Features 
* APIGateway
* SNS
* Lambda
* EC2
* CloudWatch
* Cost Analyzer 
* Tag Policies

