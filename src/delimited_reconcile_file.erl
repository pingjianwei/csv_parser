%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 七月 2017 11:49
%%%-------------------------------------------------------------------
-module(delimited_reconcile_file).
-author("jiarj").

%% API
-export([parse/2]).

parse(Config,Bin) ->
  BinListDetail = content_pase(Config,Bin),
  %lager:debug("line:~p",[length(BinListDetail)]),
  [line_to_map(Line,Config) || Line <- BinListDetail].

content_pase(Config,Bin) ->
  Delimit_line = maps:get(delimit_line, Config, undefined),
  BinList = binary:split(Bin, Delimit_line, [global, trim]),
  TotalLines = length(BinList),
  TopSkipLines = maps:get(topLines, Config, undefined),
  BottomSkipLines = maps:get(detailLines, Config, undefined),
  BottomTopLines = maps:get(topLines, Config, undefined),

  case maps:get(separation_line, Config, undefined) of
    undefined ->
      lists:sublist(BinList, BottomTopLines+1, TotalLines-TopSkipLines-BottomSkipLines);
    Separation_line when is_integer(Separation_line) ->
      Binary_separation_line = lists:nth(Separation_line,BinList),
      BinListDetail = lists:sublist(BinList, BottomTopLines+1, TotalLines-TopSkipLines-BottomSkipLines),
      F = fun_filter_line(Binary_separation_line),
      lists:filter(F , BinListDetail)
  end.

fun_filter_line(L) ->
  fun(T) ->
    T =/= L
  end.
line_to_map(Line, Config) when is_binary(Line) ->
  Delimit_field = maps:get(delimit_field, Config, undefined),
  L = binary:split(Line, Delimit_field, [global]),
  File_head = maps:get(file_head, Config, undefined),
  List = lists:zip(File_head,L),
  Field_map = maps:get(field_map, Config, undefined),
  Keys = maps:keys(Field_map),
  maps:from_list([ to_list(X,List,maps:get(X,Field_map)) || X<-Keys]).

to_list(X, List, Value) when is_tuple(Value) ->
  {Total,Text_identifier} = Value,
  Val = proplists:get_value(Total,List),
  Field = binary:replace(Val, Text_identifier,<<"">>, [global]),
  {X,Field};
to_list(X, List, FieldMap) when is_binary(FieldMap) ->
  Val = proplists:get_value(FieldMap,List),
  {X,Val}.
