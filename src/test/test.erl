%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. 六月 2017 14:07
%%%-------------------------------------------------------------------
-module(test).
-compile(export_all).
-author("jiarj").

%% API
-export([parse/2, test/0, test2/0, test3/0, test5/0]).

config() ->
  #{field_map => #{
    <<"SettleDate">> => {<<"清算日期"/utf8>>, [<<" ">>]}
    , <<"TxnTimeWithColon">> => {<<"交易时间"/utf8>>, [<<" ">>]}
    , <<"UpMchtNo">> => {<<"结算商户编号"/utf8>>, [<<" ">>]}
    , <<"TermId">> => {<<"交易终端号"/utf8>>, [<<" ">>]}
    , <<"TxnTypeChinese">> => {<<"交易类型"/utf8>>, [<<" ">>]}
    , <<"BankCardNo">> => {<<"卡号"/utf8>>, [<<" ">>]}
    , <<"TxnAmtWithDigits">> => <<"交易金额"/utf8>>
    , <<"FeeWithDigits">> => <<"商户手续费"/utf8>>
    , <<"RefId">> => {<<"参考号bit37"/utf8>>, [<<" ">>]}
    , <<"_TermSeq">> =>{<<"终端流水号bit11"/utf8>>, [<<" ">>]}
  }

    , delimit_field => [<<",">>]
    , delimit_line => [<<$\n>>]
    , skipTopLines => 1
    , skipEndLines => 0
    , headLine =>1

  }.

config3() ->
  #{
    field_map => #{
      <<"settleDate">> => <<"清算日期"/utf8>>
      , <<"txnDate">> => <<"交易日期"/utf8>>
      , <<"txnTime">> => <<"交易时间"/utf8>>
      , <<"txnAmt">> => <<"交易金额"/utf8>>
      , <<"req">> => <<"流水号"/utf8>>
    }
    , delimit_line => [<<$\r, $\n>>]
    , delimit_field => [<<"\t">>]
    , skipTopLines => 4
    , skipEndLines => 2
    , headLine =>4

  }.

config4() ->
  #{
    field_map => #{
      <<"settleDate">> => <<"清算日期"/utf8>>
      , <<"txnDate">> => <<"交易日期"/utf8>>
      , <<"txnTime">> => <<"交易时间"/utf8>>
      , <<"txnAmt">> => <<"交易金额"/utf8>>
      , <<"req">> => <<"流水号"/utf8>>
    }
    , delimit_line => [<<$\r, $\n>>]
    , delimit_field => [<<"\t">>]
    , skipTopLines => 4
    , skipEndLines => 2
    , headLine =>4
  }.

config5() ->
  #{field_map => #{
    <<"shanghuhao">> => {<<"       商户号       "/utf8>>, [<<" ">>]}
    , <<"txnDate">> => {<<"   交易日期   "/utf8>>, [<<" ">>]}
    , <<"txnTime">> => {<<"   交易时间   "/utf8>>, [<<" ">>]}
    , <<"txnAmt">> => {<<"    交易金额    "/utf8>>, [<<" ">>, <<"\,">>]}
    , <<"req">> => {<<"    流水号    "/utf8>>, [<<" ">>]}
  }
    , delimit_line => [<<"\n">>]
    , delimit_field => [<<226, 148, 130>>]
    , skipTopLines => 6
    , skipEndLines => 4
    , separation_line => 6
    , headLine =>5
  }.

config6() ->
  #{field_map => #{
    <<"traceNo">> => {28, 6},
    <<"txnTime">> => {35, 10},
    <<"cardNo">> => {46, 19},
    <<"txnAmt">> => {66, 12},
    <<"queryId">> => {87, 21},
    <<"orderId">> => {112, 32},
    <<"origTraceNo">> => {148, 6},
    <<"origTxnTime">> => {155, 10},
    <<"settleAmt">> => {180, 13},
    <<"txnType">> => {215, 2},
    <<"origQueryId">> => {271, 21},
    <<"merId">> => {293, 15},
    <<"TermId">> => {388, 8},
    <<"MerReserved">> => {397, 32},
    <<"origOrderId">> => {475, 32}
  }
    , delimit_line => [<<$\r, $\n>>]
    , skipTopLines => 0
    , skipEndLines => 0
  }.

parse(Config, Bin) ->
  Delimit_line = maps:get(delimit_line, Config, undefined),
  BinList = binary:split(Bin, Delimit_line, [global, trim]),
  TotalLines = length(BinList),
  SkipTopLines = maps:get(skipTopLines, Config, 0),
  SkipEndLines = maps:get(skipEndLines, Config, 0),
  Delimit_field = maps:get(delimit_field, Config, undefined),
  Field_map = maps:get(field_map, Config, undefined),
  HeadLine = maps:get(headLine, Config, undefined),
  Separation_line = maps:get(separation_line, Config, undefined),

  BinContent = get_content(BinList, SkipTopLines, TotalLines, SkipEndLines, Separation_line),


  case Delimit_field of
    undefined ->
      [line_to_map(Line, Field_map) || Line <- BinContent];
    Delimit_field ->
      BinHeadLine = get_file_head(BinList, HeadLine),
      ListHeadLine = headLine_to_list(BinHeadLine, hd(BinContent), Delimit_field),
      %lager:debug("line:~p",[length(BinListDetail)]),
      [line_to_map(Line, Delimit_field, ListHeadLine, Field_map) || Line <- BinContent]

  end.



get_file_head(BinList, HeadLine) when is_integer(HeadLine) ->
  lists:nth(HeadLine, BinList);
get_file_head(BinList, undefined) ->
  <<>>.

get_content(BinList, SkipTopLines, TotalLines, SkipEndLines, Separation_line) when is_integer(Separation_line) ->
  Binary_separation_line = lists:nth(Separation_line, BinList),
  BinListDetail = lists:sublist(BinList, SkipTopLines + 1, TotalLines - SkipTopLines - SkipEndLines),
  F = fun_filter_line(Binary_separation_line),
  lists:filter(F, BinListDetail)
;
get_content(BinList, SkipTopLines, TotalLines, SkipEndLines, undefined) ->
  lists:sublist(BinList, SkipTopLines + 1, TotalLines - SkipTopLines - SkipEndLines).

headLine_to_list(<<>>, L, Delimit_field) ->
  Length = length(binary:split(L, Delimit_field, [global])),
  Lists = lists:seq(1, Length),
  lists:map(fun(L) -> I = integer_to_binary(L), <<"column", I/binary>> end, Lists);
headLine_to_list(BinHeadLine, _L, Delimit_field) when is_binary(BinHeadLine) ->

  binary:split(BinHeadLine, Delimit_field, [global]).

fun_filter_line(L) ->
  fun(T) ->
    T =/= L
  end.
line_to_map(Line, Delimit_field, BinHeadLine, Field_map) when is_binary(Line) ->
  L = binary:split(Line, Delimit_field, [global]),
%%  lager:debug("L:~p",[L]),
%%  lager:debug("BinHeadLine:~p",[BinHeadLine]),
  List = lists:zip(BinHeadLine, L),
  Keys = maps:keys(Field_map),
  maps:from_list([to_list(X, List, maps:get(X, Field_map)) || X <- Keys]).

line_to_map(Line, FieldMap) ->
  Lists = maps:to_list(FieldMap),
  F = fun({Fidle, {Pos, Len}}, Acc) ->
    [{Fidle, binary:part(Line, {Pos, Len})} | Acc]
      end,
  maps:from_list(lists:foldl(F, [], Lists)).

to_list(X, List, Value) when is_tuple(Value) ->
  {Total, Text_identifier} = Value,
  Val = proplists:get_value(Total, List),
  Field = binary:replace(Val, Text_identifier, <<"">>, [global]),
  {X, Field};
to_list(X, List, FieldMap) when is_binary(FieldMap) ->
%%  lager:debug("X:~p",[X]),
%%  lager:debug("List:~p",[List]),
%%  lager:debug("FieldMap:~p",[FieldMap]),

  Val = proplists:get_value(FieldMap, List),
%%  lager:debug("Val:~p",[Val]),
  {X, Val}.



file_write(FileName,L,Lists)->
  LinesGap = 500,
  file:write_file(FileName, [], [write]),
  F = fun
        (Repo, {N, Acc, Total}) when N >= LinesGap ->
          lager:info("Write ~p lines to file:~ts", [Total, FileName]),
          file:write_file(FileName, Acc, [append]),
          %% initial new empty acc
          {1, [to_term(Repo,Lists)], Total + N};
        (Repo, {N, Acc, Total}) ->
          {N + 1, [to_term(Repo,Lists) | Acc], Total}
      end,

  {N, Rest, SubTotal}  = lists:foldl(F, {0, [], 0}, L),
  lager:info("Write ~p lines to file:~ts", [SubTotal + N, FileName]),
  file:write_file(FileName, Rest, [append]).


to_term(Repo,List) when is_list(Repo) ->
  Map = maps:from_list(Repo),
  to_term(Map,List);
to_term(Repo,List) when is_map(Repo) ->

  ValueList = lists:map(fun(Key)-> maps:get(Key,Repo) end,List),
  %ValueList = maps:values(Repo),
  ValueListWithLimit = lists:join(<<"\ ">>, ValueList),
  lists:append(ValueListWithLimit,[<<"\ ",$\r,$\n>>]).

read_line_Gap(FileName, LinesGap, F) ->
  {ok, Fd} = file:open(FileName, [raw, binary]),
  read_line(Fd, LinesGap, F),
  file:close(Fd).



read_line(Fd, LinesGap, F) ->
  read_line(Fd, <<"">>, [], 0, LinesGap, F).
read_line(_Fd, Line, eof, _, _, F) ->
  F(Line);
read_line(Fd, Line, [], N, LinesGap, F) when N >= LinesGap ->
  F(Line),
  {Line3, Sign} = case file:read_line(Fd) of
                    {ok, Line2} -> {Line2, []};
                    eof -> {<<"">>, eof}
                  end,
  read_line(Fd, Line3, Sign, 1, LinesGap, F);
read_line(Fd, Line, [], N, LinesGap, F) when N < LinesGap ->
  {Line3, Sign} = case file:read_line(Fd) of
                    {ok, Line2} -> {Line2, []};
                    eof -> {<<"">>, eof}
                  end,
  read_line(Fd, <<Line/binary, Line3/binary>>, Sign, N + 1, LinesGap, F).

length_pares() ->
  Delimit_line = [<<$\r, $\n>>],
  {ok, Bin} = file:read_file("/mnt/d/csv/INN17071888ZM_898319849000019"),

  BinList = binary:split(Bin, Delimit_line, [global, trim]),
  lager:debug("Length:~p", [length(BinList)]),
  Field_map = #{
    <<"traceNo">> => {28, 6},
    <<"txnTime">> => {35, 10},
    <<"cardNo">> => {46, 19},
    <<"txnAmt">> => {66, 12},
    <<"queryId">> => {87, 21},
    <<"orderId">> => {112, 32},
    <<"origTraceNo">> => {148, 6},
    <<"origTxnTime">> => {155, 10},
    <<"settleAmt">> => {180, 13},
    <<"txnType">> => {215, 2},
    <<"origQueryId">> => {271, 21},
    <<"merId">> => {293, 15},
    <<"TermId">> => {388, 8},
    <<"MerReserved">> => {397, 32},
    <<"origOrderId">> => {475, 32}
  },
  [line_to_map(Line, Field_map) || Line <- BinList]
.






read_line_test() ->
  F = fun(Binary) ->
    Lists = binary:split(Binary, [<<$\n>>], [global, trim]),
    lager:debug("length:~p", [length(Lists)])
      end,
  read_line_Gap("/mnt/d/test.txt", 10, F).


fwrite_test() ->
  Config = config3(),
  {ok, Bin} = file:read_file("/mnt/d/csv/20170710.txt.netbank"),
  L = parse(Config, Bin),


  Lists = [<<"settleDate">>
    , <<"txnDate">>
    , <<"txnTime">>
    , <<"txnAmt">>
    , <<"req">>],
  file_write("/mnt/d/test.txt",L, Lists).
delimited_reconcile_file() ->
  Config = config4(),
  {ok, Bin} = file:read_file("/mnt/d/csv/finance.20170705.txt.wap"),
  L = parse(Config, Bin),
  Lists = [<<"settleDate">>
    , <<"txnDate">>
    , <<"txnTime">>
    , <<"txnAmt">>
    , <<"req">>],
  file_write("/mnt/d/test.txt",L, Lists).




test() ->
  Config = config3(),
  {ok, Bin} = file:read_file("/mnt/d/csv/20170710.txt.netbank"),
  L = parse(Config, Bin),
  lager:debug("length(L):~p", [length(L)]),
  L.

test2() ->
  Config = config4(),
  {ok, Bin} = file:read_file("/mnt/d/csv/finance.20170705.txt.wap"),
  %{ok,Bin} = file:read_file("/mnt/d/csv/20170625.txt.wap"),
  L = parse(Config, Bin),
  lager:debug("length(L):~p", [length(L)]),
  L.

test3() ->
  Config = config(),
  {ok, Bin} = file:read_file("/mnt/d/csv/1234.csv"),
  L = parse(Config, Bin),
  lager:debug("length(L):~p", [length(L)]),
  L.



test5() ->
  Config = config5(),
  {ok, Bin} = file:read_file("/mnt/d/csv/p-jif1.txt"),
  L = parse(Config, Bin),
  lager:debug("length(L):~p", [length(L)]),
  L.

test6() ->
  Config = config6(),
  {ok, Bin} = file:read_file("/mnt/d/csv/INN17071888ZM_898319849000019"),
  L = parse(Config, Bin),
  lager:debug("length(L):~p", [length(L)]),
  L.



repo_to_mode() ->
  Lists = [#{id => 10697,
    mcht_full_name => <<229, 190, 144, 233, 156, 178>>,
    mcht_short_name => <<229, 190, 144, 233, 156, 178>>,
    payment_method => [gw_wap],
    quota => [{txn, -1}, {daily, -1}, {monthly, -1}],
    status => normal, up_mcht_id => <<"898350272993140">>,
    up_term_no => <<"12345678">>,
    update_ts => {1495, 508972, 229550}}
    , #{id => 10697,
      mcht_full_name => <<229, 190, 144, 233, 156, 178>>,
      mcht_short_name => <<229, 190, 144, 233, 156, 178>>,
      payment_method => [gw_wap],
      quota => [{txn, -1}, {daily, -1}, {monthly, -1}],
      status => normal, up_mcht_id => <<"898350272993140">>,
      up_term_no => <<"12345678">>,
      update_ts => {1495, 508972, 229550}}],
  Fields = [
    id,
    mcht_full_name,
    mcht_short_name,
    payment_method,
    quota,
    status,
    up_term_no,
    update_ts
  ],

  L = [to_mode(X, Fields,write) || X <- Lists],
  file_write("/mnt/d/test.txt",L, Fields)
.

fun_payment_method([Payment_method],write)->
  atom_to_binary(Payment_method, utf8);
fun_payment_method(Value,save) when is_binary(Value) ->
  [binary_to_atom(Value,utf8)].


to_mode(X, Fields,Operate) ->

  Config = #{id => integer,
    mcht_full_name => binary,
    mcht_short_name => binary,
    payment_method =>
    fun(Value,O) ->
      case O of
        write->
          [Payment_method] = Value,
          atom_to_binary(Payment_method, utf8);
        save->
          [binary_to_atom(Value,utf8)]
      end
    end
    ,
    quota =>
    fun(Value,O) ->
      case O of
        write->
          [{txn, Txn}, {daily, Daily}, {monthly, Monthly}] = Value,
          Txn_binary = integer_to_binary(Txn),
          Daily_binary = integer_to_binary(Daily),
          Monthly_binary = integer_to_binary(Monthly),
          <<Txn_binary/binary, "\,", Daily_binary/binary, "\,", Monthly_binary/binary>>;
        save->
          [Txn,Daily,Monthly] = binary:split(Value, [<<"\,">>], [global]),
          [{txn, binary_to_integer(Txn)}, {daily, binary_to_integer(Daily)}, {monthly, binary_to_integer(Monthly)}]
      end
    end,
    status => atom,
    up_mcht_id => binary,
    up_term_no => binary,
    update_ts =>
    fun(Value,O) ->
      case O of
        write->
          {Time1, Time2, Time3} = Value,
          Time1_binary = integer_to_binary(Time1),
          Time2_binary = integer_to_binary(Time2),
          Tim3_binary = integer_to_binary(Time3),
          <<Time1_binary/binary, "\,", Time2_binary/binary, "\,", Tim3_binary/binary>>;
        save->
          [Time1,Time2,Time3] = binary:split(Value, [<<"\,">>], [global]),
          {binary_to_integer(Time1), binary_to_integer(Time2), binary_to_integer(Time3)}
      end
    end
  },
  F = fun out_2_model_one_field/2,
  {VL, _, _,_} = lists:foldl(F, {[], Config, X,Operate}, Fields),
  VL
.
out_2_model_one_field(Field, {Acc, Model2OutMap, PL,Operate}) when is_atom(Field), is_list(Acc), is_map(Model2OutMap) ->
  Config = maps:get(Field, Model2OutMap),

%%  lager:debug("Config=~p,Field=~p", [Config, Field]),

  Value = do_out_2_model_one_field({Field, Config}, PL,Operate),
  %% omit undefined key/value , which means not appear in PL

  AccNew = [{Field, Value} | Acc],
  {AccNew, Model2OutMap, PL,Operate}.

do_out_2_model_one_field({KeyInPL, binary}, PL,write) when is_map(PL) ->
  maps:get(KeyInPL, PL);
do_out_2_model_one_field({KeyInPL, binary}, PL,save) when is_map(PL) ->
  maps:get(KeyInPL, PL);

do_out_2_model_one_field({KeyInPL, integer}, PL,write) when is_map(PL) ->
  Value = maps:get(KeyInPL, PL),
  integer_to_binary(Value);
do_out_2_model_one_field({KeyInPL, integer}, PL,save) when is_map(PL) ->
  Value = maps:get(KeyInPL, PL),
  binary_to_integer(Value);

do_out_2_model_one_field({KeyInPL, atom}, PL,write) when is_map(PL) ->
  Value = maps:get(KeyInPL, PL),
  atom_to_binary(Value, utf8);
do_out_2_model_one_field({KeyInPL, atom}, PL,save) when is_map(PL) ->
  Value = maps:get(KeyInPL, PL),
  binary_to_atom(Value, utf8);

do_out_2_model_one_field({KeyInPL, F}, PL,write) when is_function(F), is_map(PL) ->
  Value = maps:get(KeyInPL, PL),
  F(Value,write);
do_out_2_model_one_field({KeyInPL, F}, PL,save) when is_function(F), is_map(PL) ->
  Value = maps:get(KeyInPL, PL),
  F(Value,save).

read_mchant()->
  Config =
    #{
      field_map => #{
        id => <<"column1">>
        ,mcht_full_name => <<"column2">>
        ,mcht_short_name => <<"column3"/utf8>>
        ,payment_method => <<"column4"/utf8>>
        ,quota => <<"column5"/utf8>>
        ,status => <<"column6"/utf8>>
        ,up_term_no => <<"column7"/utf8>>
        ,update_ts => <<"column8"/utf8>>
      }
      ,delimit_field => [<<"\ ">>]
      ,delimit_line => [<<"\ ",$\r, $\n>>]
    },
  {ok,Bin} = file:read_file("/mnt/d/test.txt"),
  Lists = parse(Config,Bin),
  Fields = [
    id,
    mcht_full_name,
    mcht_short_name,
    payment_method,
    quota,
    status,
    up_term_no,
    update_ts
  ],
  [to_mode(X, Fields,save) || X <- Lists].