#!/bin/sh
# OpenVPN Statistic CGI script
# Script version 1.00 Rafal Drzymala 2013
#
# https://github.com/Rafciq/openwrt/blob/master/misc/ovpn_stat.sh
#
# Changelog
#	1.00	RD	First stable code
#
# Destination /www/cgi-bin/ovpn_stat
#

. /lib/functions.sh

print_css() {
	printf '\t<STYLE TYPE="text/css">
	@CHARSET "UTF-8";
	Body
		{
			margin: 0;
			padding: 2px;
			background-color:#000000;
			font-family: Tahoma;
			font-size: 0.8em;
			font-weight: normal;		
			color: #000000;
			scrollbar-base-color: #5C7A00; 
			scrollbar-arrow-color: #7AA300;
			scrollbar-DarkShadow-Color: #C2E066; 
		}	
	.InstanceCell
		{
			margin: 0;
			padding-top: 10px;
			padding-bottom: 10px;
			padding-left: 4px;
			padding-right: 4px;
			background-color:#296614;
			border-color: #D6EB99;
			border-style: solid;
			border-width: 2px;	
			border-radius: 8px 8px;	
			font-weight: bold;		
			text-align: center;
		}
	.InstanceText
		{
			font-size: 1.4em;
			color: #52CC29;
		}
	.SectionCell
		{
			padding: 2px;
			background-color:#47B224;
			border-color: #6B8F00;
			border-style: solid;
			border-width: 2px;	
			border-radius: 5px 5px;	
			font-weight: normal;		
			text-align: center;
		}
	.SectionText
		{
			font-size: 0.9em;
			font-weight: bold;		
			color: #2E3D00;
		}
	.ParamTable
		{
			width: 100%%;
			margin: 0;
			padding: 3px;
			background-color: #296614;
			border-style: dotted;
			border-color: #A3FF85;
			border-width: thin;	
			border-radius: 8px 8px;	
			text-align: left;
		}
	.ParamTableRow
		{
			font-size: 1em;		
			font-weight: normal;
			vertical-align: top;
		}
	.ParamTableCellName
		{
			width: 20%%;
			padding-top: 4px;
			padding-bottom: 4px;
			padding-left: 10px;
			padding-right: 10px;
			background-color:#14330A;
			border-radius: 3px 3px;	
			text-align: right;
		}
	.ParamTableTextName
		{
			font-size: 0.9em;
			font-weight: normal;		
			color: #D1FFC2;
		}
	.ParamTableCellValue
		{
			width: 80%%;
			padding-top: 4px;
			padding-bottom: 4px;
			padding-left: 10px;
			padding-right: 10px;
			background-color: #D6EB99;
			border-radius: 3px 3px;	
			text-align: left;
		}
	.ParamTableTextValue
		{
			font-size: 1em;
			font-weight: bold;		
			color: #1F4C0F;
		}
	.StatTable
		{
			width: 100%%;
			margin: 0;
			padding-top: 3px;
			padding-bottom: 3px;
			padding-left: 3px;
			padding-right: 3px;
			text-align: left;
			background-color: #99CC00;
			border-style: dotted;
			border-color: #1F4C0F;
			border-width: thin;	
			border-radius: 8px 8px;	
		}
	.StatTableHeadRow
		{
			vertical-align: top;
			background-color: #4C6600;
		}
	.StatTableHeadText
		{
			border-style: solid;
			border-color: #B8DB4D;
			border-width: 2px;
			border-radius: 5px 5px;	
			font-size: 0.7em;		
			font-style: normal;
			font-weight: normal;
			text-align: center;
			color: #D6EB99;
		}
	.StatTableOddRow
		{
			background-color: #D6EB99;
			font-size: 1em;		
			font-weight: normal;
			vertical-align: top;
		}
	.StatTableEvenRow
		{
			background-color: #E0F0B2;
			font-size: 1em;		
			font-weight: normal;
			vertical-align: top;
		}
	.StatTableCellText
		{
			padding-left: 6px;
			padding-right: 6px;
			border-radius: 3px 3px;	
			text-align: left;
			text-overflow: ellipsis;
			overflow: hidden;
			vertical-align: middle;
			color: #4C6600;
		}
	.StatTableCellNumber
		{
			padding-left: 6px;
			padding-right: 6px;
			text-align: right;
			white-space: nowrap;
			vertical-align: middle;
			color: #4C6600;
			border-radius: 3px 3px;	
		}
	.StatTableCellIP
		{
			padding-left: 6px;
			padding-right: 6px;
			border-radius: 3px 3px;	
			font-family: monospace, Consolas, Lucida Console, Terminal;
			text-align: right;
			white-space: nowrap;
			text-align: left;
			vertical-align: middle;
			color: #4C6600;
		}
	.StatTableCellMAC
		{
			padding-left: 6px;
			padding-right: 6px;
			border-radius: 3px 3px;	
			font-family: monospace, Consolas, Lucida Console, Terminal;
			text-align: right;
			white-space: nowrap;
			text-align: center;
			vertical-align: middle;
			color: #4C6600;
		}
	.StatTableCellDate
		{
			padding-left: 6px;
			padding-right: 6px;
			border-radius: 3px 3px;	
			text-align: center;
			white-space: nowrap;
			vertical-align: middle;
			color: #4C6600;
		}
	.LogArea
		{
			width: 100%%; 
			padding: 6px;
			margin-bottom: 10px;
			border-style: dotted;
			border-color: #A3FF85;
			border-width: 1px;	
			border-radius: 8px 8px;	
			background-color:#143D14;
			font-family: monospace, Consolas, Lucida Console, Terminal;
			font-size: smaller;
			text-overflow: ellipsis;
			color: #B8DB4D;
		}
	</STYLE>\n'
}

print_prefix() {
	printf "Content-type: text/html\n\n"
	printf "<!DOCTYPE html>\n"
	printf "<HTML>\n"
	printf "\t<META HTTP-EQUIV=\"pragma\" CONTENT=\"no-cache\"/>\n"
	printf "\t<META HTTP-EQUIV=\"cache-control\" CONTENT=\"no-cache\"/>\n"
	printf "\t<META HTTP-EQUIV=\"refresh\" CONTENT=\"60\">\n"
	printf "\t<META GENERATOR=\"RD_OpenVPN_Statistic\">\n"
	printf "\t<META AUTHOR=\"Rafal Drzymala\">\n"
	print_css
	printf "\t<HEAD>\n"
	printf "\t\t<TITLE>OpenVPN Statistic - $(uci get system.@system[0].hostname)</TITLE>\n"
	printf "\t</HEAD>\n"
	printf "\t<BODY>\n"
	printf "\t\t<TABLE BORDER=\"0\" WIDTH=\"100%%\">\n"
}

print_sufix() {
	printf "\t\t</TABLE>\n"
	printf "\t</BODY>\n"
	printf "</HTML>\n"
}

parse_openvpn_file() {
	local enable
	local enabled
	local status_file
	local log_file
	local status_version
	local client
	local instance
	
	config_get_bool enable  "$1" 'enable'  0
	config_get_bool enabled "$1" 'enabled' 0
	config_get status_file "$1" 'status' ""
	config_get log_file "$1" 'log' ""
	[ "$log_file" == "" ] && config_get log_file $1 'log_append'
	[ $enable -gt 0 ] && [ $enabled -gt 0 ] && return
	[ "$status_file" == "" ] && return
	[ "$log_file" == "" ] && return
	config_get_bool client "$1" 'client' 0
	config_get status_version "$1" 'status_version' "1"
	[ $client -gt 0 ] && instance="CLIENT: $1" || instance="SERVER: $1"
	printf "\t\t\t<TR>\n"
	printf "\t\t\t\t<TH CLASS=\"InstanceCell\">\n"
	printf "\t\t\t\t\t<A NAME=\"$1\">\n"
	printf "\t\t\t\t\t<DIV CLASS=\"InstanceText\">$instance</DIV>\n"
	printf "\t\t\t\t\t</A>\n"
	printf "\t\t\t\t</TH>\n"
	printf "\t\t\t</TR>\n"
	awk -v StatusVersion=$status_version '
	function AddSection(Title)
	{
		print "\t\t\t<TR>";
		print "\t\t\t\t<TH CLASS=\"SectionCell\"><DIV CLASS=\"SectionText\">",Title,"</DIV></TH>";
		print "\t\t\t</TR>";
	}
	BEGIN {
		if (StatusVersion == 3)
			FS="\t"
		else
			FS=",";
		OFS="";
		LastColCount=0;
		SubRowNo=0;
	}
	{ 
		if (NF == 1 || StatusVersion == 1)
			StartCol=1
		else if ($1 == "HEADER")
			StartCol=3;
		else
			StartCol=2;
		ColCount=(NF-StartCol)+1;
		if (SubRowNo != 0 && LastColCount != ColCount) 
		{
			print "\t\t\t\t\t</TABLE>";
			print "\t\t\t\t</TD>";
			print "\t\t\t</TR>";
			SubRowNo=0;
		}
		if (StatusVersion != 1 && $1 == "HEADER") AddSection($2);
		if (ColCount == 1) 
		{
			if ($1 != "END") AddSection($1);
		} 
		else if (ColCount == 2) 
		{
			if (SubRowNo == 0) 
			{
				print "\t\t\t<TR>";
				print "\t\t\t\t<TD>";
				print "\t\t\t\t\t<TABLE CLASS=\"ParamTable\">";
			}
			print "\t\t\t\t\t\t<TR CLASS=\"ParamTableRow\">";
			print "\t\t\t\t\t\t\t<TD CLASS=\"ParamTableCellName\"><DIV CLASS=\"ParamTableTextName\">",$1,"</DIV></TD>"
			print "\t\t\t\t\t\t\t<TD CLASS=\"ParamTableCellValue\"><DIV CLASS=\"ParamTableTextValue\">",$2,"</DIV></TD>"
			print "\t\t\t\t\t\t</TR>";
			SubRowNo=SubRowNo+1;
		} 
		else 
		{
			if (SubRowNo == 0) 
			{
				print "\t\t\t<TR>";
				print "\t\t\t\t<TD>";
				print "\t\t\t\t\t<TABLE CLASS=\"StatTable\">";
			}
			if (SubRowNo == 0)
				RowCalss="StatTableHeadRow"
			else if ((SubRowNo % 2) == 0)
				RowCalss="StatTableEvenRow"
			else
				RowCalss="StatTableOddRow";
			print "\t\t\t\t\t\t<TR CLASS=\"",RowCalss,"\">";
			for (i=StartCol; i <= NF; i++) 
			{
				if (SubRowNo == 0)
					CellClass="StatTableHeadText"
				else if ($i ~ /^[0-9]+$/)
					CellClass="StatTableCellNumber"
				else if ($i ~ /\`([0-9a-fA-F]{1,2}[:-]){5}[0-9a-fA-F]{1,2}/)
					CellClass="StatTableCellMAC"
				else if ($i ~ /\`([0-9]{1,3}\.){3}[0-9]{1,3}\:[0-9]{1,5}/)
					CellClass="StatTableCellIP"
				else if ($i ~ /\`[A-Z][a-z][a-z] [A-Z][a-z][a-z] [ 0-9][0-9] [ 0-9][0-9]:[0-9][0-9]:[0-9][0-9] [0-9]{4}/)
					CellClass="StatTableCellDate"
				else
					CellClass="StatTableCellText";
				print "\t\t\t\t\t\t\t<TD CLASS=\"",CellClass,"\"><DIV>",$i,"</DIV></TD>"
			}
			print "\t\t\t\t\t\t</TR>";
			SubRowNo=SubRowNo+1;
		} 
		LastColCount=ColCount;
	}' $status_file
	printf "\t\t\t<TR>\n"
	printf "\t\t\t\t<TH CLASS=\"SectionCell\"><DIV CLASS=\"SectionText\">LAST LOG</DIV></TH>\n"
	printf "\t\t\t</TR>\n"
	printf "\t\t\t<TR>\n"
	printf "\t\t\t\t<TD>\n"
	printf "\t\t\t\t\t<TEXTAREA CLASS=\"LogArea\" ROWS=\"10\" READONLY=\"1\">\n"
	tail -n 50 $log_file | sed '1!G;h;$!d' 
	printf "\t\t\t\t\t</TEXTAREA>\n"
	printf "\t\t\t\t</TD>\n"
	printf "\t\t\t</TR>\n"
}

config_load openvpn
print_prefix
config_foreach parse_openvpn_file openvpn
print_sufix
# Done
