mc chat
=====


Server
-----

TCP server for chat management. It is possible to send private messages to users, create your own rooms, enter and exit rooms and send private messages between users.
Messages can be of three types:
| Type| Description| Example |
|-|-|-|
|**system**|system messages sent by the server to the user|**_[SYSTEM] You has been registered as Bart_**<br> user has received a notification from server|
|**room**|messages about a room and a user: <br>[\<user>\#\<room\>] \<message\>|**_[bart#yelllow room] hi all!_** <br>User bart sent a message to the yellow room|
|**private**| private messages between two users: <br> \[-> or <- user] \<message\>|**_\[ -> bart] hi bart!_**<br>User sent a a private message to bart<br>**_\[ <- bart] how are you?_** <br>User bart sent a message to user|


Client 
-----
It is possible to use command line chat via commands in the form of tuples. The first term corresponds to the action to be performed while the following (optional) specify other parameters (for example, the stanza, the user, the message text).

| Command        | Description     | Example |
|-|-----------|------------|
|**{help}** |return the list of available commands|_{help}_|
|**{rooms}**|return the list of available rooms|_{rooms}_|
|**{users_room,"\<room\>"}**|return the list of users in a room|_{users_room, "green room"}_|
|**{create_room,"\<room name\>"}**|create a new room |_{create_room, "blue room"}_|
|**{enter_room,"\<room name\>"}**|the user will receive all messages sent in the room|_{enter_room, "yellow room"}_|
|**{exit_room,"\<room name\>"}**|the user will not receive messages sent in the room|_{exit_room, "yellow room"}_|
|**{send_room,"\<room name\>","\<message\>"}**|the user send the message to all users in the room|_{send_room, "yellow room","Hi all!"}_|
|**{send_private,"\<user name\>","\<message\>"}**|the user send a private message to user|_{send_private, "Bart","Hi! How are you?"}_|
|**{register,"\<user name\>"}**|the user sets his username|_{register, "Bart"}_|
|**{quit}**|the user leaves the chat|_{quit}_|

Database
-----
The data is stored via ETS in the following tables:
- **room**: table containing all the server rooms (system rooms and those created by users); is made up of the following fields: 
    - **name**: room name
    - **owner**: room creator user (socket)
    - **clients**: list of sockets connected to the room
    
- **users**: table containing the users connected to the server, consisting of the following fields:
    - **name**: username of the user
    - **socket**: socket associated with the user (it is also the user's identifier)Database

Use
-----
To use the chat do the following steps:
1. **clone server app:** https://github.com/crisalexITA/mc_server_app
2. **clone client app:** https://github.com/crisalexITA/mc_client_app
3. **start server:** open an os shell and go to server app folder and run _rebar shell_
4. **start client:** open an os shell and go to client app folder and run _rebar shell_
5. **register user:** from client set user nickname with _{register,"\<user name\>"}_
6. **execute commands:** use one of the commands specified above 

_* steps from 4 to 6 can be repeated several times to create more clients_


Technical Notes
-----
developed on windows platform with Erlang/OTP 24 and rebar3 in 'application' mode


