-module(dripline_conn_mgr).
-behavior(gen_server).

% internal server state
-record(state,{db_host, db_port}).

% starting and linking
-export([start_link/0]).

% gen_server callbacks
-export([init/1,handle_call/3,handle_cast/2,handle_info/2,
		terminate/2,code_change/3]).

handle_call(_Req, _From, StateData) ->
	{ok, ok, StateData}.

handle_cast(_Req, StateData) ->
	{noreply, StateData}.

handle_info(_Info, StateData) ->
	{noreply, StateData}.

start_link() ->
	start_link("p8portal.phys.washington.edu",5984).

start_link(DBHost,DBPort) ->
	gen_server:start_link(?MODULE,[DBHost,DBPort],[]).

init([DBHost,DBPort]) ->
	% try to connect to the server.  if we can't, this whole endeavor is
	% a wash.  otherwise, we're good - start normally.
	Svr = couchbeam:server_connection(DBHost,DBPort),
	case couchbeam:server_info(Svr) of
		{ok, _} ->
			{ok, #state{db_host = DBHost, db_port = DBPort}};
		_ ->
			{error, no_db_conn}
	end.

terminate(_Rsn, _StateData) ->
	ok.

code_change(_OldVsn, StateData, _Extras) ->
	{ok, StateData}.