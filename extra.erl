% Used https://learnyousomeerlang.com/more-on-multiprocessing
% Used https://stackoverflow.com/questions/34033440/return-the-number-of-times-a-value-appears-in-a-list-in-erlang
% Used http://erlang.org/doc/reference_manual/code_loading.html
-module(extra).
-compile(export_all).
-import (lists, [member/2, delete/2]).

%%  Example of concurrency using 3 functions that tell a story: Calling the police, them driving over and them knocking on your door
%%  W/o concurrency, functions called in order but are slower (shell prints the final "ok")
%%  W/ concurrency, functions work faster but the story loses meaning because priting is out of order
%%  Concurrent function also prints out PID of the last spawn, in this case the PID of spawn(extra, door, [2])


%% Run example using conc and comparison functions

phone(0) ->
    io:fwrite("Hello, what is your emergency~n");
phone(N) ->
    io:fwrite("Ring...~n"),
    phone(N-1).

siren(0) ->
    done;
siren(N) ->
    io:fwrite("WHEE-OOO~n"),
    siren(N-1).

door(0) ->
    io:fwrite("FBI, open up!~n");
door(N) ->
    io:fwrite("Knock...~n"),
    door(N-1).

conc() ->
    %% Shows concurrency...
    %% Output will be similar to: Ring... WHEE-OOO Knock...<Pid> Ring... WHEE-OOO Knock... Ring... 
                                %% WHEE-OOO FBI, open up! Hello, what is your emergency WHEE-OOO WHEE-OOO
    spawn(extra, phone, [3]),
    spawn(extra, siren, [5]),
    spawn(extra, door, [2]).

comparison() ->
    %% Shows normal output
    %% Output will be similar t0: "Ring, Ring,Ring, Hello what is your emergency, Knock, Knock, FBI open up!
    phone(3),
    siren(5),
    door(2).

%=============================================================================================
%=============================================================================================
%% ERLANG is good at multiproccessing and proccess in general, as well as communication between the system and user
%% Here is an example of such code using a fake database of usernames
%% Function playWDB() has a small DB and plays around with all types of inputs and their results

%% Run example using playWDB function or on terminal using startDB and then your own calls

database(Accounts, LoggedIn) ->
    receive 
        {From, {create, Username}} ->                           % Creates an account into the DB if unique username chosen
             case member(Username, Accounts) of
                true ->                                         % Username Taken, print error
                    From ! {self(), {username_taken, Username}},
                    database(Accounts, LoggedIn);
                false ->                                        % Username free to add to DB
                    From ! {self(), created},
                    database([Username] ++ Accounts, LoggedIn)
                end;    

        {From, {delete, Username}} ->                           % Deletes account in DB if it exists
            case member(Username, Accounts) of
                true ->                                         % Exist therefore delete
                    From ! {self(), {deleted, Username}},
                    database(delete(Username,Accounts), LoggedIn);
                false ->                                        % Does not exist so print out error
                    From ! {self(), account_not_found},
                    database(Accounts, LoggedIn)
                end;

        {From, {login, Username}} ->                            % Log into user if given valid username
            case member(Username, Accounts) of
                true ->         
                    case member(Username, LoggedIn) of
                        true ->                                         % Already In
                            From ! {self(), {already_logged_in, Username}},
                            database(Accounts, LoggedIn);
                        false ->                                        % Valid so LogIn
                            From ! {self(), logged_in},
                            database(Accounts, [Username] ++ LoggedIn)
                        end;                                            
                false ->                                                % Invalid so return error
                    From ! {self(), account_not_found},
                    database(Accounts, LoggedIn)
                end;

        {From, {logout, Username}} -> 
            case member(Username, LoggedIn) of
                true ->                                         % Exist therefore logout
                    From ! {self(), {logged_out, Username}},
                    database(Accounts, delete(Username,LoggedIn));
                false ->                                        % Does not exist so print out error
                    From ! {self(), not_logged_in},
                    database(Accounts, LoggedIn)
                end;

        finish ->
            ok
            
    end.

startDB(List) ->                        % Method to spawn DB efficiently
    spawn(extra, database, [List, []]).

% Method acting as wrappers to easily create/delete/login/logout to DB
accessDB(Pid, Username, Func) ->
    Pid ! {self(), {Func, Username}},
    receive
        {Pid, Msg} -> Msg   % Recieves message from self() call to return to user
    after 5000 ->
        timeout             %If no response in 5 seconds, exit with timeout message
    end.

% Function that calls functions to play with DB
% Note it only returns the last message received
playWDB() ->
    ID = startDB([dog, cat, mouse]),
    accessDB(ID, mouse, create),  %% Username Taken error
    accessDB(ID, meow, delete),   %% Prints Account_Not_Found
    accessDB(ID, dog, login),     %% Successful Login
    accessDB(ID, dog, login),     %% Already LoggedIn
    accessDB(ID, dog, logout),    %% Successful Logout
    accessDB(ID, dog, login),     %% Successful Login AGAIN
    accessDB(ID, mice, create),   %% Successful creation
    accessDB(ID, mouse, delete).   %% Prints {deleted,mouse}

%=============================================================================================
%=============================================================================================
%% ERLANG is terrible at expensive, large number crunching algorithms as it is quit slow compared to other languages
%% Here is an example of such expensive numbr crunching, where the slower nature or Erlang adds up per computation

%% Run example using runSlowCrunch function

numberCrunch(0, _, _) -> done;

numberCrunch(_, _, 0) -> done;

numberCrunch(LoopVal, Num, Dem) -> 
    io:fwrite("LoopVal: ~p ~n", [LoopVal]),
    crunchLoop(Num, Dem),
    numberCrunch(LoopVal -1, Num, Dem),
    numberCrunch(LoopVal -1, Num, Dem -1).

crunchLoop(Num, Dem) ->
    Result = Num / Dem,
    io:fwrite("Result: ~p ~n", [Result]).

runSlowCrunch() ->
    numberCrunch(20,2,5),
    numberCrunch(60,3,4).

%=============================================================================================
%=============================================================================================
%% Second versin of a simple number crunch: 
%% Detecting what percentage of values come up on die given roll amount

%% Run example using runSlowCrunch2 function

count(_, []) -> 0;
count(X, [X|XS]) -> 1 + count(X, XS);
count(X, [_|XS]) -> count(X, XS).

generateRollResults(Die,LstSize) ->     %%Generates list of die results in LstSize rolls
    [rand:uniform(Die) || _ <- lists:seq(1, LstSize)].

dieRollPercentage (Die, LstSize) ->     %% Main function to find percentage and print. Use this when testing
    List = generateRollResults(Die,LstSize),
    Map = maps:from_list(lists:zip(lists:seq(1, Die), lists:duplicate(Die,0))),
    NewMap = updateMap(Map, List, Die),
    printPercent(Die,LstSize,NewMap).

updateMap(Map, Lst, 1) ->               %% Creates mapping of results to amount rolled
    Val = count(1, Lst),
    maps:update(1, Val, Map);
updateMap(Map, Lst, N) ->
    Val = count(N, Lst),
    NewMap = maps:update(N, Val, Map),
    updateMap(NewMap, Lst, N-1).

printPercent(1,LstSize, Map) ->         %% Prints the percentages
    RollNum =  maps:get(1,Map),
    io:fwrite("~p: ~.3f% ~n~n", [1, RollNum/LstSize * 100]);
printPercent(N,LstSize,Map) ->
    RollNum =  maps:get(N,Map),
    io:fwrite("~p: ~.3f% ~n", [N, RollNum/LstSize * 100]),
    printPercent(N-1,LstSize,Map).

runSlowCrunch2() ->
    dieRollPercentage(20, 100000),
    dieRollPercentage(100, 500000),
    dieRollPercentage(6, 1000000),
    dieRollPercentage(4, 3000000),
    dieRollPercentage(6, 5000000).  %% This may take a few seconds...

%=============================================================================================
%=============================================================================================
%% Erlang allows functions to get upgraded while they are running. This is done by receiving the command to do so, and calling a newer version of itself via module:function()
%% To edit the code, first spawn the function. Then edit, save the change. Then pass upgrade to the Pid and the change should be added.

%% Run example in terminal by spawning process for swap then following above steps
reload() ->
    code:purge(extra),
    compile:file(extra),              %% Recompiles and loads new code FOR you
    code:load_file(extra).            

swap(N) ->
  receive
      update ->                 %% Function that updates after recompiling with change
            reload(),
            extra:swap(0);      %% Resets count

      greet ->                  %% A simple Greeting (feel free to edit)
          io:format("Hello World!~n"),
          swap(N+1);

      {echo, Msg} ->            %% A simple echoing function (feel free to edit)
        io:fwrite("~p ~n", [Msg]),
        swap(N+1);

      count ->                  %% Returns count of all time current running code been called (feel free to edit)
        io:fwrite("Current Call Count: ~p ~n", [N]),
        swap(N+1)
    end.
