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
  #{file_head => [<<"清算日期"/utf8>>
    ,<<"交易时间"/utf8>>
    ,<<"受理商户ID"/utf8>>
    ,<<"受理商户多应用"/utf8>>
    ,<<"结算商户编号"/utf8>>
    ,<<"结算商户多应用类型"/utf8>>
    ,<<"交易终端号"/utf8>>
    ,<<"交易金额"/utf8>>
    ,<<"商户手续费"/utf8>>
    ,<<"收单收益"/utf8>>
    ,<<"品牌费"/utf8>>
    ,<<"交易类型"/utf8>>
    ,<<"卡号"/utf8>>
    ,<<"发卡机构"/utf8>>
    ,<<"卡种"/utf8>>
    ,<<"收单机构BIT32"/utf8>>
    ,<<"终端流水号BIT11"/utf8>>
    ,<<"银联系统跟踪号"/utf8>>
    ,<<"REF_NO"/utf8>>
    ,<<"授权号"/utf8>>
    ,<<"原终端流水号"/utf8>>
    ,<<"原银联系统跟踪号"/utf8>>
    ,<<"源BIT37"/utf8>>
    ,<<"UMS_MCC"/utf8>>
    ,<<"是否两条线垫支"/utf8>>
    ,<<"是否分润"/utf8>>
    ,<<"受理点商户号"/utf8>>
    ,<<"商户多应用类型"/utf8>>
    ,<<"受理点分润金额"/utf8>>
    ,<<"机构分润金额"/utf8>>
    ,<<"是否清算"/utf8>>
    ,<<"受理点终端编号"/utf8>>
    ,<<"交易发起渠道"/utf8>>
    ,<<"发送机构标识码"/utf8>>
    ,<<"原清算日期"/utf8>>
    ,<<"服务点输入方式"/utf8>>
    ,<<"T0标记"/utf8>>
    ,<<"T0手续费"/utf8>>
    ,<<"新增字段3"/utf8>>
    ,<<"借贷记标记"/utf8>>
    ,<<"交换费"/utf8>>
    ,<<"转接清算费"/utf8>>
    ,<<"新增字段7"/utf8>>
    ,<<"新增字段8"/utf8>>
    ,<<"新增字段9"/utf8>>
    ,<<"订单号"/utf8>>

  ]
    ,field_map => #{<<"settleDate">> => {<<"清算日期"/utf8>>,[<<"\"">>]}
    ,<<"txnDate">> => {<<"交易时间"/utf8>>,[<<"\"">>]}
    ,<<"termid">> => {<<"结算商户编号"/utf8>>,[<<"\"">>]}
    ,<<"refid">> => {<<"交易终端号"/utf8>>,[<<"\"">>]}
    ,<<"txnAmt">> => <<"交易金额"/utf8>>
  }
    ,delimit_field => [<<",">>]
    ,delimit_line => [<<$\r, $\n>>]
    ,topLines => 1
    ,detailLines => 0

  }.

config3()->
  #{file_head => [
    <<"清算日期"/utf8>>
    ,<<"交易日期"/utf8>>
    ,<<"交易时间"/utf8>>
    ,<<"终端号"/utf8>>
    ,<<"交易金额"/utf8>>
    ,<<"清算金额"/utf8>>
    ,<<"手续费"/utf8>>
    ,<<"流水号"/utf8>>
    ,<<"交易类型"/utf8>>
    ,<<"参考号"/utf8>>
    ,<<"卡号"/utf8>>
    ,<<"商户号"/utf8>>
    ,<<"发卡行"/utf8>>
    ,<<"卡类型"/utf8>>
    ,<<"商户订单号"/utf8>>
    ,<<"银商订单号"/utf8>>
    ,<<"支付类型"/utf8>>

  ]
    ,field_map => #{
    <<"settleDate">> => <<"清算日期"/utf8>>
    ,<<"txnDate">> => <<"交易日期"/utf8>>
    ,<<"txnTime">> => <<"交易时间"/utf8>>
    ,<<"txnAmt">> => <<"交易金额"/utf8>>
    ,<<"req">> => <<"流水号"/utf8>>
  }
    ,delimit_field => [<<"\t">>]
    ,delimit_line => [<<$\r, $\n>>]
    ,topLines => 4
    ,detailLines => 2

  }.

config4()->
  #{file_head => [
    <<"清算日期"/utf8>>
    ,<<"交易日期"/utf8>>
    ,<<"交易时间"/utf8>>
    ,<<"交易金额"/utf8>>
    ,<<"终端号"/utf8>>
    ,<<"清算金额"/utf8>>
    ,<<"手续费"/utf8>>
    ,<<"流水号"/utf8>>
    ,<<"交易类型"/utf8>>
    ,<<"参考号"/utf8>>
    ,<<"卡号"/utf8>>
    ,<<"商户号"/utf8>>
    ,<<"发卡行"/utf8>>
    ,<<"卡类型"/utf8>>
    ,<<"商户订单号"/utf8>>
    ,<<"银商订单号"/utf8>>
    ,<<"支付类型"/utf8>>
    ,<<"实际支付金额"/utf8>>
    ,<<"备注"/utf8>>
    ,<<"付款附言"/utf8>>
    ,<<"钱包优惠金额"/utf8>>

  ]
    ,field_map => #{
    <<"settleDate">> => <<"清算日期"/utf8>>
    ,<<"txnDate">> => <<"交易日期"/utf8>>
    ,<<"txnTime">> => <<"交易时间"/utf8>>
    ,<<"txnAmt">> => <<"交易金额"/utf8>>
    ,<<"req">> => <<"流水号"/utf8>>
  }
    ,delimit_field => [<<"\t">>]
    ,delimit_line => [<<$\r, $\n>>]
    ,topLines => 4
    ,detailLines => 2
  }.

config5() ->
  #{file_head => [
    <<"head">>
    ,<<"商户号"/utf8>>
    ,<<"交易日期"/utf8>>
    ,<<"交易时间"/utf8>>
    ,<<"终端号"/utf8>>
    ,<<"交易类型"/utf8>>
    ,<<"卡号"/utf8>>
    ,<<"交易金额"/utf8>>
    ,<<"清算金额"/utf8>>
    ,<<"手续费"/utf8>>
    ,<<"参考号"/utf8>>
    ,<<"流水号"/utf8>>
    ,<<"商户名称"/utf8>>
    ,<<"卡类型"/utf8>>
    ,<<"商户订单号"/utf8>>
    ,<<"支付类型"/utf8>>
    ,<<"银商订单号"/utf8>>
    ,<<"发卡行"/utf8>>
    ,<<"rest">>

  ]
    ,field_map => #{
    <<"shanghuhao">> => {<<"商户号"/utf8>>,[<<" ">>]}
    ,<<"txnDate">> => {<<"交易日期"/utf8>>,[<<" ">>]}
    ,<<"txnTime">> => {<<"交易时间"/utf8>>,[<<" ">>]}
    ,<<"txnAmt">> => {<<"交易金额"/utf8>>,[<<" ">>,<<"\,">>]}
    ,<<"req">> => {<<"流水号"/utf8>>,[<<" ">>]}
  }
    ,delimit_field => [<<226,148,130>>]
    ,delimit_line => [<<"\n">>]
    ,topLines => 6
    ,detailLines => 4
    ,separation_line => 6
  }.

pase_test()->
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



  ?assertEqual(length(L),1369),
  ?assertEqual(length(L5),5828),
  ?assertEqual(length(L4),4396),
  ?assertEqual(length(L3),33).
