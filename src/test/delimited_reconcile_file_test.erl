%%%-------------------------------------------------------------------
%%% @author jiarj
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. 七月 2017 13:37
%%%-------------------------------------------------------------------
-module(delimited_reconcile_file_test).
-include_lib("eunit/include/eunit.hrl").
-author("jiarj").

%% API
-compile(export_all).

config()->
  #{
    field_map => #{<<"settleDate">> => {<<"清算日期"/utf8>>,[<<"\"">>]}
      ,<<"txnDate">> => {<<"交易时间"/utf8>>,[<<"\"">>]}
      ,<<"termid">> => {<<"结算商户编号"/utf8>>,[<<"\"">>]}
      ,<<"refid">> => {<<"交易终端号"/utf8>>,[<<"\"">>]}
      ,<<"txnAmt">> => <<"交易金额"/utf8>>
    }
    ,delimit_field => [<<",">>]
    ,delimit_line => [<<$\n>>]
    ,skipTopLines => 1
    ,skipEndLines => 0
    ,headLine =>1

  }.

config3()->
  #{
    field_map => #{
      <<"settleDate">> => <<"清算日期"/utf8>>
      ,<<"txnDate">> => <<"交易日期"/utf8>>
      ,<<"txnTime">> => <<"交易时间"/utf8>>
      ,<<"txnAmt">> => <<"交易金额"/utf8>>
      ,<<"req">> => <<"流水号"/utf8>>
    }
    ,delimit_field => [<<"\t">>]
    ,delimit_line => [<<$\r, $\n>>]
    ,skipTopLines => 4
    ,skipEndLines => 2
    ,headLine =>4

  }.

config4()->
  #{
    field_map => #{
      <<"settleDate">> => <<"conclum1">>
      ,<<"txnDate">> => <<"conclum2">>
      ,<<"txnTime">> => <<"conclum3"/utf8>>
      ,<<"txnAmt">> => <<"conclum5"/utf8>>
      ,<<"req">> => <<"conclum9"/utf8>>
    }
    ,delimit_field => [<<"\t">>]
    ,delimit_line => [<<$\r, $\n>>]
    ,skipTopLines => 4
    ,skipEndLines => 2
  }.

config5() ->
  #{field_map => #{
    <<"shanghuhao">> => {<<"       商户号       "/utf8>>,[<<" ">>]}
    ,<<"txnDate">> => {<<"   交易日期   "/utf8>>,[<<" ">>]}
    ,<<"txnTime">> => {<<"   交易时间   "/utf8>>,[<<" ">>]}
    ,<<"txnAmt">> => {<<"    交易金额    "/utf8>>,[<<" ">>,<<"\,">>]}
    ,<<"req">> => {<<"    流水号    "/utf8>>,[<<" ">>]}
  }
    ,delimit_line => [<<"\n">>]
    ,delimit_field => [<<226,148,130>>]
    ,skipTopLines => 6
    ,skipEndLines => 4
    ,separation_line => 6
    ,headLine =>5
  }.

config6() ->
  #{field_map => #{
    <<"traceNo">> => {28,6},
    <<"txnTime">> => {35,10},
    <<"cardNo">> => {46,19},
    <<"txnAmt">> => {66,12},
    <<"queryId">> => {87,21},
    <<"orderId">> => {112,32},
    <<"origTraceNo">> => {148,6},
    <<"origTxnTime">> => {155,10},
    <<"settleAmt">> => {180,13},
    <<"txnType">> => {215,2},
    <<"origQueryId">> => {271,21},
    <<"merId">> => {293,15},
    <<"TermId">> => {388,8},
    <<"MerReserved">> => {397,32},
    <<"origOrderId">> => {475,32}
  }
    ,delimit_line => [<<$\r, $\n>>]
    ,skipTopLines => 0
    ,skipEndLines => 0
  }.

pase1_test()->
  Config3 = config3(),
  {ok,Bin3} = file:read_file("tests/20170625.txt.netbank"),
  L3 = delimited_reconcile_file:parse(Config3,Bin3),

  Config4 = config4(),
  {ok,Bin4} = file:read_file("tests/20170625.txt.wap"),
  L4 = delimited_reconcile_file:parse(Config4,Bin4),

  Config5 = config5(),
  {ok,Bin5} = file:read_file("tests/p-jif1.txt"),
  L5 = delimited_reconcile_file:parse(Config5,Bin5),

  Config = config(),
  {ok,Bin} = file:read_file("tests/test.csv"),
  L = delimited_reconcile_file:parse(Config,Bin),

  Config6 = config6(),
  {ok,Bin6} = file:read_file("tests/INN17071888ZM_898319849000018"),
  L6 = delimited_reconcile_file:parse(Config6,Bin6),

  ?assertEqual(length(L),4084),
  ?assertEqual(length(L5),5828),
  ?assertEqual(length(L6),1207),
  ?assertEqual(length(L4),4396),
  ?assertEqual(length(L3),33).

fwrite_test()->
  Config = config3(),
  {ok,Bin} = file:read_file("tests/20170625.txt.netbank"),
  L = delimited_reconcile_file:parse(Config,Bin),


  Lists = [<<"settleDate">>
    ,<<"txnDate">>
    ,<<"txnTime">>
    ,<<"txnAmt">>
    ,<<"req">>],
  ?assertEqual(delimited_reconcile_file:file_write("tests/test.txt",L,Lists),ok).
