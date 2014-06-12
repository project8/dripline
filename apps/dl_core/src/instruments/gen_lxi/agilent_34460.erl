%%%===================================================================
%%% @author Ben LaRoque
%%%===================================================================
-module(agilent_34460).

-behavior(dl_gen_instrument).

-export([handle_get/2,
         handle_set/3]).

%%====================================================================
%% API
%%====================================================================

%% gen_instrument
%%--------------------------------------------------------------------
handle_get(read, StateData) ->
    {send, <<"READ?">>, StateData};
handle_get(status, StateData) ->
    {send, <<"*STB?">>, StateData};
handle_get(trig_count, StateData) ->
    {send, <<"TRIG:COUN?">>, StateData};
handle_get(trig_sour, StateData) ->
    {send, <<"TRIG:SOUR?">>, StateData};
handle_get(Locator, StateData) ->
    {error, {bad_get, {unknown_locator, Locator}}, StateData}.

handle_set(trig_coun, Value, StateData) ->
    {send, <<"TRIG:COUN ", Value>>, StateData};
handle_set(trig_sour, Value, StateData) ->
    {send, <<"TRIG:SOUR ", Value>>, StateData};
handle_set(Locator, _Value, StateData) ->
    {error, {bad_set, {unknown_locator, Locator}}, StateData}.
