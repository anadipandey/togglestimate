set t0 [clock clicks -millisec]
#-------------------------------------------------------------------------------------------------------------------------------------------------------
proc word_search {word} {
	set path [pwd]
	set f [open $path/circuit.v r+ ]
	set data [read $f]
	set occurance [lsearch -exact -all $data $word]
	set i [ expr { [lindex $occurance 1] + 1 } ]
	set fff 1	
	set var3 { }	
	while {$fff} {
		set var [lindex $data $i]
		set del [string index $var end]
		set flag [string match $del ";"]
		set var2 [split $var {"," ";"}]
		set var2 [lreplace $var2 end end]
		set var3 [concat $var3 $var2]
		if {$flag == 1} {
			set fff 0
		}
		incr i
	}
close $f
return $var3
}

#-----------------------------------------------------------------------------------------------------------------------------------------------------

proc scan_search { } {
set scan_cell [gate_search dff]
set scan_cell [lreplace $scan_cell 0 0]
set c 0
foreach {i} $scan_cell {
	set p [lindex $i 1]
	set scan_cell [lreplace $scan_cell $c $c $p]
	incr c
	}
return $scan_cell
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------
proc gate_search {gate} {
	set path [pwd]
	set f [open $path/circuit.v r+ ]
	set data [read $f]
	set occurance [lsearch -exact -all $data $gate]
	if {[string match $gate "not" ]} {
		set occurance [lreplace $occurance 0 2]	}
	set expression { }
	set y "\("
    set z [subst $y]
	set p "\)"
	set w [subst $p]
	foreach  { var4 } $occurance {
		set i [ expr { $var4 + 1 } ]
		set var [lindex $data $i]
		set var5 [split $var {"," ")" "("}]		
		set var5 [lreplace $var5 end end]
		set var5 [lreplace $var5 0 0]
		set var6 [lindex $var5 0]
		set var5 [lreplace $var5 0 0]
		switch $gate { 			
			and 
			{ set var5 [join $var5 "."] }
			or
			{ set var5 [join $var5 "+"] }
			not
			{
			set xx !
			set var5 [append xx $var5]
			}
			nand
			{ set var5 [join $var5 "."] 
			  set xx $z
			  set var5 [append xx $var5]
			  set xx !
			  set var5 [append xx $var5]
			  #set xx $z
			  #set var5 [append xx $var5]
			  set xx $w
			  set var5 [append var5 $xx ]
			  #set var5 [append var5 $xx ]  
			}
			nor
			{ set var5 [join $var5 "+"] 
			  set xx $z
			  set var5 [append xx $var5]
			  set xx !
			  set var5 [append xx $var5]
			  #set xx $z
			  #set var5 [append xx $var5]
			  set xx $w
			  set var5 [append var5 $xx ]
			  #set var5 [append var5 $xx ]  }
		}
		set var6 [append var6 "="]
		set var6 [append var6 $var5]
	 	lappend expression $var6
	}
close $f
return $expression
}
#----------------------------------------------------------------------------------------------------------------------------------------------------
proc hold_symbol {gate} {
	set path [pwd]
	set f [open $path/circuit.v r+ ]
	set data [read $f]
	set occurance [lsearch -exact -all $data $gate]
	if {[string match $gate "not" ]} {
		set occurance [lreplace $occurance 0 2
]	}
	set symbol { }
	foreach  { var4 } $occurance {
		set i [ expr { $var4 + 1 } ]
		set var [lindex $data $i]
		set var5 [split $var {"," ")" "("}]		
		set var5 [lreplace $var5 end end]
		set var5 [lreplace $var5 0 0]
		set var6 [lindex $var5 0]
		set var5 [lreplace $var5 0 0]
		switch $gate { 			
			and 
			{ set var5 [join $var5 "."] 
			set sym "." }
			or
			{ set var5 [join $var5 "+"] 
			set sym "+" }
			not
			{
			set xx !
			set var5 [append xx $var5]
			set sym "!" }
			nand
			{ set var5 [join $var5 "&"] 
			set sym "&"}
			nor
			{ set var5 [join $var5 "^"] 
			set sym "^"}
		}
		set var6 [append var6 "="]
		set var6 [append var6 $var5]
	 	lappend symbol $sym
	}
close $f
return $symbol
}
#----------------------------------------------------------------------------------------------------------------------------------------------------
proc arrangement { } {
set arrangement_list_1 [gate_search not]
set arrangement_list_2 [gate_search and]
set arrangement_list_3 [gate_search or]
set arrangement_list_4 [gate_search nand]
set arrangement_list_5 [gate_search nor]
set arrangement_list [concat $arrangement_list_1 $arrangement_list_2 $arrangement_list_3 $arrangement_list_4 $arrangement_list_5]
return $arrangement_list
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------
proc sym_ext { } {
set sym_list_1 [hold_symbol not]
set sym_list_2 [hold_symbol and]
set sym_list_3 [hold_symbol or]
set sym_list_4 [hold_symbol nand]
set sym_list_5 [hold_symbol nor]
set symbol_list [concat $sym_list_1 $sym_list_2 $sym_list_3 $sym_list_4 $sym_list_5]
return $symbol_list
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------
proc scan_cell { } {
set scan_cell [gate_search dff]
set scan_cell [lreplace $scan_cell 0 0]
set c 0
foreach {i} $scan_cell {
	set p [lindex $i 0]
	set p [split $p "="]
	set p [lindex $p 1]
	set scan_cell [lreplace $scan_cell $c $c $p]
	incr c
	}
return $scan_cell
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------
proc boolean_functions { } {
set boolean_expression { }
foreach {input} [arrangement] {
	set X [new_exp $input]
	set tempr [split $input "="]
	set Y [lindex $tempr 0]
	append Y "="
	append Y $X
	lappend boolean_expression $Y
}
return $boolean_expression
}
#------------------------------------------------------------------------------------------------------------------------------------------------------
proc new_exp {old_exp} {	
	set new_expr ""
	set y "\("
    set z [subst $y]
	set p "\)"
	set w [subst $p]
	set f 0
	set pi [ word_search input ]
	set scan_cells [scan_cell]
	set pi [concat $pi $scan_cells]
	set temp [split $old_exp "="] 
	set func_old_exp [lindex $temp 1]
	for { set i 0 } { $i < [llength $func_old_exp] } { incr i } {
		set func_old_exp [lreplace $func_old_exp $i $i [string trim [lindex $func_old_exp $i] "!"]]
			}
	set out_old_exp [lindex $temp 0]
	set ip_old_exp [split $func_old_exp { "(" ")" "+" "." "^" "&" }]
set ip_old_exp [lsort -unique $ip_old_exp]
	
if { [lindex $ip_old_exp 0] == "" } {
set ip_old_exp [lreplace $ip_old_exp 0 0]	
}
	set all_exp [arrangement]
	set out_all_exp { }
	foreach value $all_exp {
		set value [split $value "="]
		set value [lindex $value 0]
		lappend out_all_exp $value
		}
	set ip_new_exp { }
	foreach value $ip_old_exp {
		set flag [lsearch $pi $value]
		set lvalue $value
		if { $flag == -1 } {
			set pos [lsearch $out_all_exp $value]
			set xx "("
			set lvalue1 [lreplace $lvalue 0 0 [new_exp [lindex $all_exp $pos]]] 
			lappend ip_new_exp [lindex $lvalue1 0]	
		}
		if { $flag != -1 } {
			lappend ip_new_exp $value
			}
		}
		set sym_all_exp [sym_ext] 
		set temp2 [lsearch $all_exp $old_exp]
		set sym_old_exp [lindex $sym_all_exp $temp2]
		if { [ expr { $sym_old_exp == "!" } ] } {
			set str1 [join $ip_new_exp ""]
			append sym_old_exp $str1
			set f 1
			set new_expr $sym_old_exp

				}

		if { [ expr { $sym_old_exp == "&" } ] } {
					set new_expr [join $ip_new_exp "."]
					set xx $z
					set new_expr [append xx $new_expr]
					set xx "!"
					set new_expr [append xx $new_expr]
					#set xx $z
					#set new_expr [append xx $new_expr]
					set xx $w
					set new_expr [append new_expr $xx ]
					#set new_expr [append new_expr $xx ]
					set f 1
				}
				if { [ expr { $sym_old_exp == "^" } ] } {
					set new_expr [join $ip_new_exp "+"] 
					set xx $z
					set new_expr [append xx $new_expr]
					set xx "!"
					set new_expr [append xx $new_expr]
					#set xx $z
					#set new_expr [append xx $new_expr]
					set xx $w
					set new_expr [append new_expr $xx ]
					#set new_expr [append new_expr $xx ]
					set f 1
				}
		if { [ expr { $f == 0 } ] } {
				set new_expr [join $ip_new_exp $sym_old_exp]
				}
			set xx "("
			append xx $new_expr
			append xx ")"
			return $xx
	
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------

proc fanout {input} {
	set list_of_exp [arrangement]
	set count 1
        #set scan_serch [scan_search]
	#set flag [lsearch -exact $scan_serch $input]
	#if {$flag != "-1"} {
	#		incr count
	#	}
	foreach value $list_of_exp {
		set list_of_ip_var [split $value {"="}]
		set list_of_ip_var [lindex $list_of_ip_var 1]
		set list_of_ip_var [split $list_of_ip_var {"!" "." "+" "&" "^" "(" ")"}]		
		set flag [lsearch -exact $list_of_ip_var $input]
		set flag [join $flag ""]		
		if {$flag != "-1"} {
			incr count
			}
		
		
	}
return $count
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------
proc pow {x {y}} {
set power  1
    for {set s 0} { $s < $y } { incr s } {
        set power [expr { $x*$power } ]
    }
return $power
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------
proc extract_var {function {s_c}} {
	set list_of_var_m { }
	set list_of_var [split $function {"(" ")" "+" "." "!" "&" "^" }]
	set list_of_var [lsort -unique $list_of_var]
	set list_of_var [lreplace $list_of_var 0 0]
	set pos_of_scan_cell [lsearch $list_of_var $s_c]
	set list_of_var [lreplace $list_of_var $pos_of_scan_cell $pos_of_scan_cell]
	set list_of_var [join $list_of_var " "]
	set s_c [split $s_c]
	set list_of_var [linsert $list_of_var 0 $s_c]
	return $list_of_var
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------
proc truth_table {function {s_c}} {
	set list_of_var [extract_var $function $s_c]
	
	set n [llength $list_of_var]
	set combinations  [pow 2 $n]
	set truth_table { }
	for { set k 0 } {$k < $combinations } {incr k} {
		set seq $k
		set seqence { }
		for {set i 0} {$i < $n} {incr i} {
			set oo [expr {$seq % 2} ] 
			set seq [expr {$seq/2} ]
			lappend seqence $oo		
		}
		set f $function
		for {set s 0} {$s < [llength $seqence]} {incr s} {
			regsub -all [lindex $list_of_var $s] $f [lindex $seqence $s] f
		}
#puts "expression for $function wrt $s_c : $f and sequence : $seqence and variables : $list_of_var"
#puts "\n"
		    set f [split $f "+"]
			set f [join $f "||"]
		    set f [split $f "."]
		    set f [join $f "&&"]
		    set f [split $f ")" ] 
		    set f [join $f "\}\]" ]
		    set f [split $f "("]
		    set f [join $f "\[expr \{"]
		    set f [string trim $f {"[" "]"}]
		    set cmd $f
		    set out [eval $cmd] 
		lappend truth_table $out
	}
set truth_table [join $truth_table ""]
return $truth_table
}
#-----------------------------------------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------------------------------------
puts "================================================================================================================================================"
puts "================================================================================================================================================"
puts "************************************************************************circuit_description*****************************************************"
puts "================================================================================================================================================"
puts "================================================================================================================================================"
puts "\n"
puts "Primary inputs of circuit"
puts "\n"
set pi [puts [ word_search input ]]

puts "\n"
puts "Primary output of circuit"
puts "\n"
set po [puts [word_search output]]

puts "\n"
puts "intermidiate circuit nodes"
puts "\n"
set circuit_nodes [puts [word_search wire]]

puts "\n"
puts "Arrangement of logic gates in circuit"
puts "\n"
set arrangement_of_gates [puts [arrangement ]]
puts "\n"
puts "Here symbol & , ^ used for nad gate and nor gate respectivlly"

puts "\n"
puts "extracted sybols of arrangements"
puts "\n"
set symbols [puts [sym_ext ]]

puts "\n"
puts "scan cells of circuit"
puts "\n"
set scan_cells [puts [scan_cell]]
puts "\n"
set scan_serch [puts [scan_search]]
puts "============================================================================================================================================="
puts "\n"
puts "Boolean function of each intermidiate circuit node"
puts "\n"
set Boolean_func [puts [boolean_functions]]
puts "================================================================================================================================================"
puts "\n"
puts "set of effected circuit nodes due to transistion of a scan_cell"
puts "\n"
foreach {cell} [scan_cell] {
	puts "effected circuit nodes due to transision of scan cell $cell "
	puts "\n"	
	set effected_function_of_($cell) { }	
	set effected_nodes_of_($cell) { }
	set Boolean_func [boolean_functions]
	foreach {boolean_exp} $Boolean_func {
		set temp [split $boolean_exp "="]
		set function [lindex $temp 1]
		set node [lindex $temp 0]
    		set temp [lindex $temp 1]
    		set temp [split $temp {"(" ")"}]
    		set temp [join $temp ""]
    		set temp [split $temp { "(" ")" "+" "." "!" "&" "^" }]
		set flag [lsearch -exact $temp $cell]
		set flag [join $flag ""]		
		if {$flag != "-1"} {
			lappend effected_nodes_of_($cell) $node
			lappend effected_function_of_($cell) $function
		}
	}
	puts $effected_nodes_of_($cell)	
	puts "\n"
}
puts "================================================================================================================================================"
puts "\n"
puts "fanout of effected circuit nodes due to transistion of a scan_cell"
puts "\n"
foreach {cell} [scan_cell] {
	set fanout_of_set_of_($cell) { }
	set list1 $effected_nodes_of_($cell)
	puts "fanouts of nodes in scan cell $cell "
	puts "\n"	
	foreach {fan_in} $list1 {
		set fan_out [fanout $fan_in]
		lappend fanout_of_set_of_($cell) $fan_out
	}
	puts $fanout_of_set_of_($cell)	
	puts "\n"
}
puts "================================================================================================================================================"
#puts "\n"
#puts "truth table of effected sets"
#puts "\n"
foreach {cell} [scan_cell] {
	set trutu_table_for_($cell) { }
	foreach {function} $effected_function_of_($cell) {
		set table [truth_table $function $cell]
		lappend trutu_table_for_($cell) $table	
	}
#puts "truth table for scan cell $cell"
#puts $trutu_table_for_($cell)
}	
#puts "================================================================================================================================================"
puts "\n"
puts "boolean_diffrence of effected sets"
puts "\n"
foreach {cell} [scan_cell] {
	set bd_for_($cell) { }
	foreach {function} $effected_function_of_($cell) {
		set bd { }		
		set table [truth_table $function $cell]
		set table [split $table {}]
		for {set i 0} {$i < [llength $table]} {incr i 2} {
			set first [lindex $table $i]
			set second [lindex $table  [ expr {$i+1} ] ] 
			set f_s [string match $first $second]
			switch $f_s {
				1 { lappend bd 0}
				0 { lappend bd 1}
			}
		}
		set bd [join $bd ""]
		lappend bd_for_($cell) $bd	
	}
puts "boolean differnce for scan cell $cell"
puts $bd_for_($cell)
}
puts "================================================================================================================================================"
puts "\n"
puts "probability of boolean_diffrence of effected sets"
puts "\n"
foreach {cell} [scan_cell] {
	set p_bd_for_($cell) { }
	foreach {bdiff} $bd_for_($cell) {	
		set tab [split $bdiff {}]
		set tot_case [llength $tab]
		
		set fav_case [llength [lsearch -exact -all $tab "1"]]
		set aaa [expr { double($fav_case) / $tot_case } ]
		set aaa [expr { $aaa * 0.5 }]
		lappend p_bd_for_($cell) $aaa	
	}
puts "probability of boolean differnce for scan cell $cell"
puts $p_bd_for_($cell)
}
puts "================================================================================================================================================"
puts "\n"
puts "Switching activity parameter for scan cells sets"
puts "\n"
foreach {cell} [scan_cell] {
	set c4 0	
	set SAP_($cell) 0
	
	foreach {fan} $fanout_of_set_of_($cell) {	
		set tem [lindex $p_bd_for_($cell) $c4]	
		set res [expr { $fan * $tem }]
		set SAP_($cell) [expr { $SAP_($cell) + $res}]		
		incr c4
	}
	puts "Switching activity parameter for scan cell $cell"
puts $SAP_($cell)

}
puts "================================================================================================================================================"
puts "\n"
puts "scan chain order"
set s_c_o { }
foreach {cell} [scan_cell] {
	set temp_2 { }
	lappend temp_2 $cell	
	lappend temp_2 $SAP_($cell)
	lappend s_c_o $temp_2
	}
set temp_3 [lsort -real -index 1 $s_c_o]
set s_c_o { }
foreach value $temp_3 {
lappend s_c_o [lindex $value 0]
}
puts "\{$s_c_o\}"
puts "================================================================================================================================================="
puts "\n"
puts "total time tacken"
puts stderr "[expr {([clock clicks -millisec]-$t0)/1000.}] sec" ;# RS
