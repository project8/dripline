%%%===================================================================
%%% @author Ben LaRoque
%%%===================================================================
-module(gen_lxi_bus).

-behavior(dl_gen_bus).
-behaviour(gen_server).

%%%===================================================================
%%% API exports
%%%===================================================================
%% dl_gen_bus
-export([start_link/4]).
-export([get/2,
         set/3]).

%% gen_server
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {name,
                ip,
                port,
                module,
                mod_state,
                sockets}).

%%%===================================================================
%%% API functions
%%%===================================================================

%% dl_gen_bus
%%--------------------------------------------------------------------
start_link(Name, Address, Port, Module) ->
    lager:notice("attempting to start_link an lxi bus"),
    gen_server:start_link({local, Name}, ?MODULE, [Name, Address, Port, Module], []).

get(Instrument, Channel) ->
    gen_server:call(Instrument, {get, Channel}, infinity).

set(Instrument, Channel, Value) ->
    gen_server:call(Instrument, {set, Channel, Value}, infinity).

%% gen_server
%%--------------------------------------------------------------------
init([DeviceName, Address, Port, Module]) ->
    lager:notice("init of lxi bus"),
    {ok, #state{name=DeviceName,
                ip=Address,
                port=Port,
                module=Module,
                sockets=[]}}.

handle_call({get, Channel}, From, #state{name=N, ip=IP, port=Port, module=M,
                                         mod_state=ModSt, sockets=Sockets}=State) ->
    {ok, Socket} = gen_tcp:connect(IP, Port, [binary, {packet, 0}]),
    NewSockets = lists:append(Sockets, [{Socket, [], From, ok}]),
    ok = M:handle_get(Channel, ModSt),%
    {noreply, State#state{sockets=NewSockets}};
handle_call({set, Channel, Value}, From, #state{name=N, ip=IP, port=Port, module=M, 
                                                mod_state=ModSt, sockets=Sockets}=State) ->
    {ok, Socket} = gen_tcp:connect(IP, Port, [binary, {packet, 0}]),
    NewSockets = lists:append(Sockets, [{Socket, [], From, ok}]),
    ok = M:handle_get(Channel, ModSt),%
    {noreply, State#state{sockets=NewSockets}};
handle_call(Request, _From, State) ->
    lager:warning("Got unexpected call:~n~p", [Request]),
    {reply, call_unimplemented, State}.

handle_cast(_Msg, State) ->
    {noreply, cast_unimplemented, State}.

handle_info({tcp, Socket, Data}, #state{sockets=Socs, module=M}=State) ->
    S = lists:keyfind(Socket, 1, Socs),
    case S of
        false ->
            {stop, socket_not_found, State};
        {Socket, Resp, From, _Status} ->
            NewResp = M:parse_message(Socket, {Resp, Data, From}),
            {noreply, done_check(Socket, NewResp, State)};
        _ ->
            {stop, malformed_state_entry, State}
    end;
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
done_check(Socket, {continue, NewResponse}, #state{sockets=Socs}=State) ->
    {Socket, _Resp, From, Status} = lists:keyfind(Socket, 1, Socs),
    S = lists:keyreplace(Socket, 1, Socs, {Socket, NewResponse, From, Status}),
    State#state{sockets=S};
done_check(Socket, {error, NewResponse}, #state{sockets=Socs}=State) ->
    {Socket, _Resp, From, _Status} = lists:keyfind(Socket, 1, Socs),
    S = lists:keyreplace(Socket, 1, Socs, {Socket, NewResponse, From, error}),
    State#state{sockets=S};
done_check(Socket, {done, NewResponse}, #state{sockets=Socs}=State) ->
    {Socket, _Resp, From, Status} = lists:keyfind(Socket, 1, Socs),
    gen_server:reply(From, {Status, NewResponse}),
    gen_tcp:close(Socket),
    State#state{sockets=lists:keydelete(Socket, 1, Socs)}.
