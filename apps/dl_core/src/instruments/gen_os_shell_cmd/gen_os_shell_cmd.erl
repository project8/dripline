%%%-------------------------------------------------------------------
%%% @author Ben LaRoque
%%%
%%% Created: 9 May 2014 by Ben Laroque
% gen_os_shell_cmd.erl
% Behavior for "instruments" which are really operating system
% commands.  The behavior module wraps a gen_server, and the
% callback module defines its 'base' command, and a list of
% valid options.  When the execute command is sent in, the base
% command along with the options that are passed in is executed
% via os:cmd.
-module(gen_os_shell_cmd).
-behaviour(gen_server).

-record(state,{mod, mod_state, port, from, data}).

%%--------------------------------------------------------------------
%% API
%%--------------------------------------------------------------------
-export([start_link/2,
         get/2,
         set/3]).
%%--------------------------------------------------------------------
%% gen_server
%%--------------------------------------------------------------------
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

%%--------------------------------------------------------------------
%% API Functions
%%--------------------------------------------------------------------
start_link(CallbackMod, ID) ->
    gen_server:start_link({local, ID}, ?MODULE, [CallbackMod], []).

get(Instrument, Channel) ->
    gen_server:call(Instrument, {get, Channel}).

set(Instrument, Channel, Value) ->
    gen_server:call(Instrument, {set, Channel, Value}).

%%--------------------------------------------------------------------
%% gen_server Functions
%%--------------------------------------------------------------------
init([CallbackMod]=Args) ->
    case CallbackMod:init(Args) of
        {ok, ModStateData} = _StartOK ->
            StateData = #state{mod = CallbackMod,
                               mod_state = ModStateData,
                               port = none,
                               from = none,
                               data = []},
            {ok, StateData};
        Failure ->
            Failure
        end.

handle_call({get, Channel}, From, #state{mod=Mod, mod_state=ModSt, from=none}=State) ->
    %{reply, OsCmd, NewModSt} = Mod:handle_get(Channel, ModSt),
    case Mod:handle_get(Channel, ModSt) of
        {reply, OsCmd, NewModSt} ->
            Port = erlang:open_port({spawn, OsCmd}, [exit_status, stderr_to_stdout]),
            {noreply, State#state{port=Port, from=From, mod_state=NewModSt}};
        {error, {Type, Details}, NewModSt} ->
            lager:notice("constructing error"),
            {reply, construct_err_response({error, {Type, Details}}), State}
        end;
            
handle_call({set, Channel, Value}, From, #state{mod=Mod, mod_state=ModSt, from=none}=State) ->
    {reply, OsCmd, NewModSt} = Mod:handle_set(Channel, Value, ModSt),
    Port = erlang:open_port({spawn, OsCmd}, [exit_status, stderr_to_stdout]),
    {noreply, State#state{port=Port, from=From, mod_state=NewModSt}};
handle_call(_Args, _From, #state{from=_F}=State)->
    lager:warning("shell is busy"),
    {reply, busy, State};
handle_call(_Request, _From, State) ->
    lager:warning("os_shell unknown request"),
    {stop, unrecognized_request, State}.

handle_cast(_Request, State) ->
    {noreply, State}.

handle_info({P, {data, Data}}, #state{port=P, data=OldData}=State) ->
    {noreply, State#state{data=[OldData|Data]}};
handle_info({P, {exit_status, Status}}, #state{port=P, from=From, data=Data}=State) ->
    FlatList = lists:flatten(Data),
    Reply = construct_response(Status, FlatList),
    gen_server:reply(From, Reply),
    {noreply, State#state{port=none, from=none, data=[]}};
handle_info(_Info, State) ->
    {reply, State}.

terminate(_Request, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%--------------------------------------------------------------------
%% helper Functions
%%--------------------------------------------------------------------
construct_err_response({error, {_Class, _Error}=E}) ->
    D0 = dl_data:new(),
    D1 = dl_data:set_data(D0, E),
    D2 = dl_data:set_code(D1, error),
    dl_data:set_ts(D2, dl_util:make_ts()).

construct_response(Status, Data)->
    D0 = dl_data:new(),
    D1 = set_err_code(Status, dl_data:set_data(D0, erlang:list_to_binary(Data))),
    dl_data:set_ts(D1, dl_util:make_ts()).

set_err_code(0, Dl_data) ->
    dl_data:set_code(Dl_data, ok);
set_err_code(_NonZero, Dl_data) ->
    dl_data:set_code(Dl_data, error).
