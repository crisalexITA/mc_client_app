%%%-------------------------------------------------------------------
%% @doc mc_client public API
%% @end
%%%-------------------------------------------------------------------

-module(mc_client_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    mc_client_sup:start_link(),
    startClient().

stop(_State) ->
    ok.

%% internal functions
startClient() ->
    connect().

readInput(Socket) -> 
    % read input
    {ok, Input} = io:read(">>"),
    try
        case Input of 
            % command list
            {help} ->
                help();
            % room list
            {rooms} ->
                rooms(Socket);
            % room users list
            {users_room, Room} ->
                usersRoom(Socket, cast2String(Room));
            % create room
            {create_room, Room} ->
                createRoom(Socket, cast2String(Room));
            % enter room
            {enter_room, Room} ->
                enterRoom(Socket, cast2String(Room));
            {exit_room, Room} ->
                exitRoom(Socket, cast2String(Room));
            % quit client
            {quit} ->
                quit(Socket);
            % send message to room
            {send_room, Room, Message} ->
                sendRoom(Socket, cast2String(Room), cast2String(Message));
            % send private message 
            {send_private, User, Message} ->
                sendPrivate(Socket, cast2String(User), cast2String(Message));
            % register name
            {register, Name} ->
                registerName(Socket, cast2String(Name))
        end
    catch
        error:Error-> 
            io:format("[SYSTEM] command not found, type {help} to get a list of available commands~n"),
            {error, Error}
    end,   
    readInput(Socket).

connect() -> 
    {ok, Socket} = gen_tcp:connect("localhost", 6666, [{active, false}, {packet, 0}]),
    
    timer:sleep(1),

    spawn_link(fun() -> recv(Socket) end),
    spawn_link(fun() -> readInput(Socket) end),
    
    gen_tcp:send(Socket, term_to_binary({connect})),
    timer:sleep(infinity).

help() -> 
    Rooms = "{rooms}: get a list of all available rooms",
    RegisterName = "{register_name, \"<name>\"}: get your username",
    SendRoom = "{send_room, \"<room>\", \"<message>\"}: send a message in a room",
    SendPrivate = "{send_private, \"<user>\", \"<message>\"}: send a message to a user",
    CreateRoom = "{create_room, \"<room>\"}: create a room",
    UsersRoom = "{users_room, \"<room>\"}: get a list of users in a room",
    ExitRoom = "{exit_room, \"<room>\"}: exit room",
    EnterRoom = "{enter_room, \"<room>\"}: enter room",
    io:format("~n~n"),
    io:format("\r[SYSTEM] here a list of available commands:~n~s~n~s~n~s~n~s~n~s~n~s~n~s~n~s~n", [Rooms, RegisterName, SendRoom, SendPrivate, CreateRoom, UsersRoom, ExitRoom, EnterRoom]),
    io:format("~n~n").

quit(Socket) ->
    gen_tcp:send(Socket, term_to_binary({quit})),
    io:format("Bye~n"),
    exit(self(), quit).

recv(Socket) ->
    {ok, A} = gen_tcp:recv(Socket, 0),
    io:format("\r~p~n", [A]),
    recv(Socket).

rooms(Socket) ->
    gen_tcp:send(Socket, term_to_binary({rooms})).

registerName(Socket, Name) ->
    gen_tcp:send(Socket, term_to_binary({register, Name})).

sendRoom(Socket, Room, Message) ->
    gen_tcp:send(Socket, term_to_binary({send_message_room, Room, Message})).

sendPrivate(Socket, User, Message) ->
    gen_tcp:send(Socket, term_to_binary({send_message_private, User, Message})).

createRoom(Socket, Room) ->
    gen_tcp:send(Socket, term_to_binary({create_room, Room})).

usersRoom(Socket, Room) ->
    gen_tcp:send(Socket, term_to_binary({users_room, Room})).

exitRoom(Socket, Room) ->
    gen_tcp:send(Socket, term_to_binary({exit_room, Room})).

enterRoom(Socket, Room) ->
    gen_tcp:send(Socket, term_to_binary({enter_room, Room})).

cast2String(Variable) ->
    case is_atom(Variable) of
        true -> atom_to_list(Variable);
        false -> Variable
    end.