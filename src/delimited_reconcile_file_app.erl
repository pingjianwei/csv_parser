%%%-------------------------------------------------------------------
%% @doc delimited_reconcile_file public API
%% @end
%%%-------------------------------------------------------------------

-module(delimited_reconcile_file_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    delimited_reconcile_file_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
