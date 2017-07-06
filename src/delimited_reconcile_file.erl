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
  Delimit_line = maps:get(delimit_line, Config, undefined),
  BinList = binary:split(Bin, Delimit_line, [global, trim]),
  TotalLines = length(BinList),
  SkipTopLines = maps:get(skipTopLines, Config, undefined),
  SkipEndLines = maps:get(skipEndLines, Config, undefined),
  Delimit_field = maps:get(delimit_field, Config, undefined),
  Field_map = maps:get(field_map, Config, undefined),
  HeadLine = maps:get(headLine, Config, undefined),
  BinHeadLine = get_file_head(BinList,HeadLine),

  Separation_line = maps:get(separation_line, Config, undefined),

  BinContent = get_content(BinList,SkipTopLines,TotalLines,SkipEndLines,Separation_line),

  ListHeadLine = headLine_to_list(BinHeadLine,hd(BinContent),Delimit_field),

  %lager:debug("line:~p",[length(BinListDetail)]),
  [line_to_map(Line,Delimit_field,ListHeadLine,Field_map) || Line <- BinContent].


get_file_head(BinList,HeadLine) when is_integer(HeadLine)->
  lists:nth(HeadLine,BinList);
get_file_head(BinList,undefined) ->
  <<>>.

get_content(BinList,SkipTopLines,TotalLines,SkipEndLines,Separation_line) when is_integer(Separation_line)->
  Binary_separation_line = lists:nth(Separation_line,BinList),
  BinListDetail = lists:sublist(BinList, SkipTopLines+1, TotalLines-SkipTopLines-SkipEndLines),
  F = fun_filter_line(Binary_separation_line),
  lists:filter(F , BinListDetail)
;
get_content(BinList,SkipTopLines,TotalLines,SkipEndLines,undefined) ->
  lists:sublist(BinList, SkipTopLines+1, TotalLines-SkipTopLines-SkipEndLines).

headLine_to_list(<<>>,L,Delimit_field)->
  Length = length(binary:split(L, Delimit_field, [global])),
  Lists = lists:seq(1,Length),
  lists:map(fun(L)-> I = integer_to_binary(L),<<"column",I/binary>> end,Lists);
headLine_to_list(BinHeadLine,_L,Delimit_field) when is_binary(BinHeadLine)->

  binary:split(BinHeadLine, Delimit_field, [global]).

fun_filter_line(L) ->
  fun(T) ->
    T =/= L
  end.
line_to_map(Line, Delimit_field,BinHeadLine,Field_map) when is_binary(Line) ->
  L = binary:split(Line, Delimit_field, [global]),
  List = lists:zip(BinHeadLine,L),
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

