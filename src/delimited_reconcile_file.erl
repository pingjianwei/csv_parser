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
-export([parse/2,read_line_fold/3, write_to_file/5, write_to_file/6]).

%%---------------------------------------------------------------------------------------
parse(Config,Bin) ->
  Delimit_line = maps:get(delimit_line, Config, undefined),
  BinList = binary:split(Bin, Delimit_line, [global, trim]),
  TotalLines = length(BinList),
  SkipTopLines = maps:get(skipTopLines, Config, 0),
  SkipEndLines = maps:get(skipEndLines, Config, 0),
  Delimit_field = maps:get(delimit_field, Config, undefined),
  Field_map = maps:get(field_map, Config, undefined),
  HeadLine = maps:get(headLine, Config, undefined),
  Separation_line = maps:get(separation_line, Config, undefined),

  BinContent = get_content(BinList,SkipTopLines,TotalLines,SkipEndLines,Separation_line),


  case Delimit_field of
    undefined->
      [line_to_map(Line,Field_map) || Line <- BinContent];
    Delimit_field ->
      BinHeadLine = get_file_head(BinList,HeadLine),
      ListHeadLine = headLine_to_list(BinHeadLine,hd(BinContent),Delimit_field),
      %lager:debug("line:~p",[length(BinListDetail)]),
      [line_to_map(Line,Delimit_field,ListHeadLine,Field_map) || Line <- BinContent]

  end.


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

line_to_map(Line, FieldMap) ->
  Lists = maps:to_list(FieldMap),
  F = fun({Fidle,{Pos,Len}},Acc)->
    [{Fidle,binary:part(Line,{Pos,Len})} | Acc ]
      end,
  maps:from_list(lists:foldl(F,[],Lists)).
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

%%---------------------------------------------------------------------------------------

write_to_file(FileName,L,Field,Delimit_field,Delimit_line)->
  LinesGap = 500,
  file:write_file(FileName, [], [write]),
  F = fun
        (Repo, {N, Acc, Total}) when N >= LinesGap ->
          lager:info("Write ~p lines to file:~ts", [Total, FileName]),
          file:write_file(FileName, Acc, [append]),
          %% initial new empty acc
          {1, [to_term(Repo,Field,Delimit_field,Delimit_line)], Total + N};
        (Repo, {N, Acc, Total}) ->
          {N + 1, [to_term(Repo,Field,Delimit_field,Delimit_line) | Acc], Total}
      end,

  {N, Rest, SubTotal}  = lists:foldl(F, {0, [], 0}, L),
  lager:info("Write ~p lines to file:~ts", [SubTotal + N, FileName]),
  file:write_file(FileName, Rest, [append]).

write_to_file(FileName, L, Lists,Delimit_field,Delimit_line,[append])->
  Prpol = lists:map(fun(X)-> to_term(X,Lists,Delimit_field,Delimit_line) end,L),
  file:write_file(FileName, Prpol, [append]).

to_term(Repo,List,Delimit_field,Delimit_line) when is_list(Repo) ->
  Map = maps:from_list(Repo),
  to_term(Map,List,Delimit_field,Delimit_line);
to_term(Repo,List,Delimit_field,Delimit_line) when is_map(Repo) ->

  ValueList = lists:map(fun(Key)-> maps:get(Key,Repo) end,List),
  %ValueList = maps:values(Repo),
  ValueListWithLimit = lists:join(Delimit_field, ValueList),
  lists:append(ValueListWithLimit,[Delimit_line]).
%%---------------------------------------------------------------------------------------
read_line_fold(F,FileName,LinesGap)->
  {ok, Fd} = file:open(FileName, [raw, binary]),
  read_line(Fd,LinesGap,F),
  file:close(Fd).


read_line(Fd, LinesGap, F) ->
  read_line(Fd, <<"">>, [], [0,0], LinesGap, F).
read_line(_Fd, Line, eof, [N,Total], _, F) ->
  lager:info("F:~p lines to file:~ts", [Total+N-1]),
  F(Line);
read_line(Fd, Line, [], [N,Total], LinesGap, F) when N >= LinesGap ->
  lager:info("F:~p lines to file:~ts", [Total]),
  F(Line),
  {Line3, Sign} = case file:read_line(Fd) of
                    {ok, Line2} -> {Line2, []};
                    eof -> {<<"">>, eof}
                  end,
  read_line(Fd, Line3, Sign, [1,Total+N], LinesGap, F);
read_line(Fd, Line, [], [N,Total], LinesGap, F) when N < LinesGap ->
  {Line3, Sign} = case file:read_line(Fd) of
                    {ok, Line2} -> {Line2, []};
                    eof -> {<<"">>, eof}
                  end,
  read_line(Fd, <<Line/binary, Line3/binary>>, Sign, [N + 1,Total], LinesGap, F).

