#!/bin/bash

#创建临时表
hive -e "create table if not exists ads_nshop.tmp_platform_flow_stat_g1(
    customer_gender int comment '性别：1男 0女',
    age_range string comment '年龄段',
    customer_natives string comment '所在地区',
    visit_avg_duration int comment '人均页面访问时长',
    visit_avg_counts int comment '人均页面访问数',
    bdp_day string
)
row format delimited fields terminated by '\t';"

#向临时表插入数据
hive -e "insert into ads_nshop.tmp_platform_flow_stat_g1
select customer_gender,
age_range,customer_natives,visit_avg_duration,
visit_avg_counts,bdp_day
from ads_nshop.platform_flow_stat_g1
where bdp_day='20190907';"

#向mysql表插入数据
sqoop export \
--connect "jdbc:mysql://hadoop01:3306/nshop_report?useUnicode=true&characterEncoding=utf-8" \
--username root \
--password 123456 \
--table platform_flow_stat_g1 \
--fields-terminated-by '\t' \
--export-dir hdfs://hadoop02:9000/user/hive/warehouse/ads_nshop.db/tmp_platform_flow_stat_g1/*

#删除临时表
hive -e "drop table ads_nshop.tmp_platform_flow_stat_g1;"
