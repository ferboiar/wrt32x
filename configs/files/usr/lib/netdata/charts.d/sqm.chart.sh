# shellcheck shell=bash
# no need for shebang - this file is loaded from charts.d.plugin
# SPDX-License-Identifier: GPL-3.0-or-later

# netdata
# real-time performance and health monitoring, done right!
# (C) 2016 Costa Tsaousis <costa@tsaousis.gr>
#

# if this chart is called X.chart.sh, then all functions and global variables
# must start with X_

# _update_every is a special variable - it holds the number of seconds
# between the calls of the _update() function
sqm_update_every=

# global variables to store our collected data
# remember: they need to start with the module name sqm_
sqm_qdisc_bytes=0
sqm_qdisc_drops=0
sqm_qdisc_backlog=0

# associative arrays
declare -A sqm_tns

# indexed arrays
declare -a sqm_tns_vals_traffic_kb
declare -a sqm_tns_vals_traffic_thres
declare -a sqm_tns_vals_latency_target
declare -a sqm_tns_vals_latency_peak
declare -a sqm_tns_vals_latency_average
declare -a sqm_tns_vals_latency_sparse
declare -a sqm_tns_vals_drops_backlog_backlog
declare -a sqm_tns_vals_drops_backlog_acks
declare -a sqm_tns_vals_drops_backlog_drops
declare -a sqm_tns_vals_drops_backlog_ecn
declare -a sqm_tns_vals_flows_sparse
declare -a sqm_tns_vals_flows_bulk
declare -a sqm_tns_vals_flows_unresponsive

# load external functions
. /usr/share/libubox/jshn.sh

# perform the query of tc to get qdisc output
sqm_query_tc() {
  local jsn
  local ifc="$1"
  
  jsn=$(tc -s -j qdisc show dev "$ifc") || return 1
  
  # strip leading & trailing []
  jsn="${jsn#[}" ; jsn="${jsn%]}"

  echo "$jsn"
}

sqm_set_overall() {
  # Overall
  json_get_vars bytes drops backlog

  sqm_qdisc_bytes=$bytes
  sqm_qdisc_drops=$drops
  sqm_qdisc_backlog=$backlog
}

sqm_set_tins() {
  local tin i ifr

  # empty all the arrays
  sqm_tns_vals_traffic_kb=()
  sqm_tns_vals_traffic_thres=()
  sqm_tns_vals_latency_target=()
  sqm_tns_vals_latency_peak=()
  sqm_tns_vals_latency_average=()
  sqm_tns_vals_latency_sparse=()
  sqm_tns_vals_drops_backlog_backlog=()
  sqm_tns_vals_drops_backlog_acks=()
  sqm_tns_vals_drops_backlog_drops=()
  sqm_tns_vals_drops_backlog_ecn=()
  sqm_tns_vals_flows_sparse=()
  sqm_tns_vals_flows_bulk=()
  sqm_tns_vals_flows_unresponsive=()

  # Options
  json_select options
  json_get_vars bandwidth diffserv
  json_select ".."

  # Tins
  # Flows & delays indicate the state as of the last packet that flowed through, so they appear to get stuck.
  # Discard the results from a stuck tin.
  json_get_keys tins tins
  json_select tins

  ifr="${ifc//[!0-9A-Za-z]/_}"
  
  i=0
  for tin in $tins; do
    json_select "$tin"
    tn="${sqm_tns[$ifc]:$((i<<1)):2}"

    json_get_vars threshold_rate sent_bytes sent_packets backlog_bytes target_us peak_delay_us avg_delay_us base_delay_us drops ecn_mark ack_drops sparse_flows bulk_flows unresponsive_flows

    eval osp="\$osp${ifr}t${i}"
    if  [ "$osp" ] && [ "$osp" -eq "$sent_packets" ] ; then
      peak_delay_us=0; avg_delay_us=0; base_delay_us=0
      sparse_flows=0; bulk_flows=0; unresponsive_flows=0
    else
      eval "osp${ifr}t${i}=$sent_packets"
    fi

    sqm_tns_vals_traffic_kb[i]=$sent_bytes
    sqm_tns_vals_traffic_thres[i]=$threshold_rate
    sqm_tns_vals_latency_target[i]=$target_us
    sqm_tns_vals_latency_peak[i]=$peak_delay_us
    sqm_tns_vals_latency_average[i]=$avg_delay_us
    sqm_tns_vals_latency_sparse[i]=$base_delay_us
    sqm_tns_vals_drops_backlog_backlog[i]=$backlog_bytes
    sqm_tns_vals_drops_backlog_acks[i]=$ack_drops
    sqm_tns_vals_drops_backlog_drops[i]=$drops
    sqm_tns_vals_drops_backlog_ecn[i]=$ecn_mark
    sqm_tns_vals_flows_sparse[i]=$sparse_flows
    sqm_tns_vals_flows_bulk[i]=$bulk_flows
    sqm_tns_vals_flows_unresponsive[i]=$unresponsive_flows

    json_select ..
    i=$((i+1))
  done
  json_select ..
}

sqm_create_overall() {
  local ifc="$1"
  local offset="$2"

  cat << EOF
CHART "SQM.${ifc}_overview" '' "SQM qdisc $ifc Overview" '' "${ifc} Qdisc" '' line $((sqm_priority + offset)) $sqm_update_every
DIMENSION 'bytes' 'Kb/s' incremental 1 125
DIMENSION 'backlog' 'Backlog/B' incremental 1 1
DIMENSION 'drops' 'Drops/s' incremental 1 1
EOF
}

sqm_create_tins() {
  local tin i j
  local ifc="$1"
  local offset="$2"

  # Options
  json_select options
  json_get_vars bandwidth diffserv
  json_select ".."

  case "$diffserv" in
      besteffort)
        sqm_tns[$ifc]="T0"
        ;;
      diffserv3)
        sqm_tns[$ifc]="BKBEVI"
        ;;
      diffserv4)
        sqm_tns[$ifc]="BKBEVIVO"
        ;;
      diffserv5)
        sqm_tns[$ifc]="LEBKBEVIVO"
        ;;
      *)
        sqm_tns[$ifc]="T0T1T2T3T4T5T6T7"
        ;;
  esac

  # Tins
  # Flows & delays indicate the state as of the last packet that flowed through, so they appear to get stuck.
  # Discard the results from a stuck tin.
  json_get_keys tins tins
  json_select tins
  i=0
  j=0
  for tin in $tins; do
      json_select "$tin"
      tn="${sqm_tns[$ifc]:$((i<<1)):2}"
      
      cat << EOF
CHART "SQM.${ifc}_${tn}_traffic" '' "CAKE $ifc $tn Traffic" 'Kb/s' "${ifc} ${tn}" 'traffic' line $((sqm_priority + offset + 1 + j)) $sqm_update_every
DIMENSION 'bytes' 'Kb/s' incremental 1 125
DIMENSION 'thres' 'Thres' absolute 1 125
CHART "SQM.${ifc}_${tn}_latency" '' "CAKE $ifc $tn Latency" 'ms' "${ifc} ${tn}" 'latency' line $((sqm_priority + offset + 2 + j)) $sqm_update_every
DIMENSION 'tg' 'Target' absolute 1 1000
DIMENSION 'pk' 'Peak' absolute 1 1000
DIMENSION 'av' 'Avg' absolute 1 1000
DIMENSION 'sp' 'Sparse' absolute 1 1000
CHART "SQM.${ifc}_${tn}_drops" '' "CAKE $ifc $tn Drops/s" 'Drops/s' "${ifc} ${tn}" 'drops' line $((sqm_priority + offset + 3 + j)) $sqm_update_every
DIMENSION 'ack' 'Ack' incremental 1 1
DIMENSION 'drops' 'Drops' incremental 1 1
DIMENSION 'ecn' 'Ecn' incremental 1 1
CHART "SQM.${ifc}_${tn}_backlog" '' "CAKE $ifc $tn Backlog" 'Bytes' "${ifc} ${tn}" 'backlog' line $((sqm_priority + offset + 4 + j)) $sqm_update_every
DIMENSION 'backlog' 'Backlog' absolute 1 1
CHART "SQM.${ifc}_${tn}_flows" '' "CAKE $ifc $tn Flow Counts" 'Flows' "${ifc} ${tn}" 'flows' line $((sqm_priority + offset + 5 + j)) $sqm_update_every
DIMENSION 'sp' 'Sparse' absolute 1 1
DIMENSION 'bu' 'Bulk' absolute 1 1
DIMENSION 'un' 'Unresponsive' absolute 1 1
EOF
      i=$((i+1))
      j=$((j+5))
      json_select ..
  done
  json_select ..
}

sqm_get() {
  # do all the work to collect / calculate the values
  # for each dimension
  #
  # Remember:
  # 1. KEEP IT SIMPLE AND SHORT
  # 2. AVOID FORKS (avoid piping commands)
  # 3. AVOID CALLING TOO MANY EXTERNAL PROGRAMS
  # 4. USE LOCAL VARIABLES (global variables may overlap with other modules)

  local jsn
  local ifc="$1"

  jsn=$(sqm_query_tc "$ifc") || return 1

  json_load "${jsn}"
  json_get_var qdisc kind

  case "$qdisc" in
      cake)
        sqm_set_overall
        sqm_set_tins
        ;;
      mq|fq_codel)
        sqm_set_overall
        ;;

      *) echo "Unknown qdisc type '$qdisc' on interface '$ifc'" 1>&2
        return 1
        ;;
  esac

  json_cleanup

  # this should return:
  #  - 0 to send the data to netdata
  #  - 1 to report a failure to collect the data
  return 0
}

# _check is called once, to find out if this chart should be enabled or not
sqm_check() {
  # this should return:
  #  - 0 to enable the chart
  #  - 1 to disable the chart

  # check that we have the tc binary
  require_cmd tc || return 1

  # check that we can collect data for each interface
  for ifc in "${sqm_ifc[@]}"; do
    sqm_query_tc "$ifc" &>/dev/null || return 1
  done

  return 0
}

# _create is called once, to create the charts
sqm_create() {
  local jsn ifc offset

  # offset is the value for ensuring charts are incrementing for priority order
  offset=0
  for ifc in "${sqm_ifc[@]}"; do
    jsn=$(sqm_query_tc "$ifc") || return 1

    json_load "${jsn}"
    json_get_var qdisc kind

    case "$qdisc" in
        cake)
          sqm_create_overall "$ifc" "$offset"
          sqm_create_tins "$ifc" "$offset"
          ;;
        mq|fq_codel)
          sqm_create_overall "$ifc" "$offset"
          ;;

        *) echo "Unknown qdisc type '$qdisc' on interface '$ifc'" 1>&2
        return 1
        ;;
    esac

    json_cleanup
    offset=$((offset+50))
  done

  return 0
}

# _update is called continuously, to collect the values
sqm_update() {
  # the first argument to this function is the microseconds since last update
  # pass this parameter to the BEGIN statement (see bellow).

  local ifc i

  for ifc in "${sqm_ifc[@]}"; do
    sqm_get "$ifc" || return 1

    # write the result of the work.
    cat << VALUESOF
BEGIN "SQM.${ifc}_overview" $1
SET 'bytes' = $sqm_qdisc_bytes
SET 'backlog' = $sqm_qdisc_drops
SET 'drops' = $sqm_qdisc_backlog
END
VALUESOF

    # get the number of tins as length of the tin
    # string in sqm_tns for the given interface / 2
    # since each tin is represented by a two char id
    num_tins=$((${#sqm_tns[$ifc]} / 2))

    for ((i=0; i<num_tins; i++)); do
      tn="${sqm_tns[$ifc]:$((i<<1)):2}"

      cat << VALUESOF
BEGIN "SQM.${ifc}_${tn}_traffic" $1
SET 'bytes' = ${sqm_tns_vals_traffic_kb[i]}
SET 'thres' = ${sqm_tns_vals_traffic_thres[i]}
END
BEGIN "SQM.${ifc}_${tn}_latency" $1
SET 'tg' = ${sqm_tns_vals_latency_target[i]}
SET 'pk' = ${sqm_tns_vals_latency_peak[i]}
SET 'av' = ${sqm_tns_vals_latency_average[i]}
SET 'sp' = ${sqm_tns_vals_latency_sparse[i]}
END
BEGIN "SQM.${ifc}_${tn}_drops" $1
SET 'ack' = ${sqm_tns_vals_drops_backlog_acks[i]}
SET 'drops' = ${sqm_tns_vals_drops_backlog_drops[i]}
SET 'ecn' = ${sqm_tns_vals_drops_backlog_ecn[i]}
END
BEGIN "SQM.${ifc}_${tn}_backlog" $1
SET 'backlog' = ${sqm_tns_vals_drops_backlog_backlog[i]}
END
BEGIN "SQM.${ifc}_${tn}_flows" $1
SET 'sp' = ${sqm_tns_vals_flows_sparse[i]}
SET 'bu' = ${sqm_tns_vals_flows_bulk[i]}
SET 'un' = ${sqm_tns_vals_flows_unresponsive[i]}
END
VALUESOF
    done
  done

  return 0
}
