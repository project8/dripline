%%%-------------------------------------------------------------------
%%% @author Jared Kofron <jared.kofron@gmail.com>
%%% @copyright (C) 2014, Jared Kofron
%%% @doc
%%%
%%% @end
%%% Created : 10 Feb 2014 by Jared Kofron <jared.kofron@gmail.com>
%%%-------------------------------------------------------------------
-module(agilent_e3631a).
-behavior(gen_gpib_spoller).

-export([start_link/4,
     init/1,
     handle_stb/2,
     handle_esr/2,
     handle_get/2,
     handle_set/3,
     sre_register_bitmask/1,
     ese_register_bitmask/1
    ]).

-record(state, {}).

-define(srq_asserted(X), ((X bsr 6) band 1) == 1).
-define(mav_asserted(X), ((X bsr 4) band 1) == 1).

sre_register_bitmask(_) ->
    176.
ese_register_bitmask(_) ->
    61.

init([]) ->
    {ok, #state{}}.

start_link(InstrName, GPIBAddress, BusMod, BusName) ->
    gen_gpib_spoller:start_link(?MODULE, InstrName, GPIBAddress, BusMod, BusName).

handle_get(output, StateData) ->
    {send, <<"OUTP:STAT?">>, StateData};
handle_get('25V', StateData) ->
    {send, <<"APPL?">>, StateData};
handle_get(_Any, StateData) ->
    lager:warning("unimplemented get"),
    {error, unimplemented, StateData}.

handle_set(output, Value, StateData) ->
    {send, [<<"OUTP:STAT ">>, Value], StateData};
handle_set('25V', NewValue, StateData) ->
    Branch = case unpack_value(NewValue) of
        {ok, Parsed} ->
            ToSend = ["APPL P25V,", Parsed],
            {send, ToSend, StateData};
        {error, Reason} ->
            {error, Reason, StateData}
    end,
    Branch;
handle_set(_Any, _Value, StateData) ->
    {error, unimplemented, StateData}.

%% 
%% If there is a message available, that is the highest priority. 
%% Otherwise, we retrieve errors or clear the status byte as necessary.
%%
handle_stb(StatusByte, StateData) when ?srq_asserted(StatusByte) ->
    case StatusByte of
    _MsgAvail when ?mav_asserted(StatusByte) ->
        {retrieve_data, StateData};
    Err when Err =:= 224; Err =:= 144; Err =:= 192; Err =:= 208 ->
        {retrieve_error, <<"err?">>, StateData};
    ESR when ESR =:= 96; ESR =:= 112 ->
        {fetch_esr, <<"*esr?">>, StateData}
    end;
handle_stb(StatusByte, StateData) ->
    case StatusByte of
    Err when Err =:= 160; Err =:= 80; Err =:= 128; Err =:= 144 ->
        {retrieve_error, <<"err?">>, StateData};
    ESR when ESR =:= 32; ESR =:= 48 ->
        {fetch_esr, <<"*esr?">>, StateData};
    _MsgAvail when ?mav_asserted(StatusByte) ->
        {retrieve_data, StateData}
    end.

handle_esr(1, StateData) ->
    {op_complete, StateData};
handle_esr(Err, StateData) when Err =:= 8; Err =:= 33; Err =:= 9; Err =:= 32 ->
    {retrieve_error, <<"syst:err?">>, StateData}.


%% Internal
-spec unpack_value(binary()) -> {ok, binary()} | {error, term()}.
unpack_value(Bin) ->
    case binary:match(Bin, <<",">>) of
        nomatch ->
            parse_const_mode(Bin);
        _Match ->
            parse_reg_mode(Bin)
    end.

-spec parse_const_mode(binary()) -> {ok, term()} | {error, term()}.
parse_const_mode(B) ->
    case {is_v(B), is_c(B)} of
        {true, false} ->
            {ok, [drop_v(B), ", ", <<"MAX">>]};
        {false, true} ->
            {ok, [<<"MAX">>, ", ", drop_c(B)]};
        _Other ->
            {error, {badval, B}}
    end.

-spec parse_reg_mode(binary()) -> binary().
parse_reg_mode(B) ->
    [V, C] = binary:split(B, <<",">>),
    case {is_v(V), is_c(V), is_v(C), is_c(C)} of
        {true, false, false, true} ->
            {ok, [drop_v(V), ", ", drop_c(C)]};
        {false, true, true, false} ->
            {ok, [drop_v(C), ", ", drop_c(V)]};
        _Other ->
            {error, {badval, B}}
    end.

-spec is_v(binary()) -> boolean().
is_v(B) ->
    binary:last(B) == $V.

-spec is_c(binary()) -> boolean().
is_c(B) ->
    binary:last(B) == $A.

-spec drop_v(binary()) -> binary().
drop_v(Bin) ->
    binary:replace(Bin, <<"V">>, <<>>).

-spec drop_c(binary()) -> binary().
drop_c(Bin) ->
    binary:replace(Bin, <<"A">>, <<>>).
