menu main off
menu graphics off
menu color off
menu tkcon off

set server [socket -server accept_client 12345]
puts "Listening cl-vmd on port 12345"

proc accept_client {sock addr port} {
    puts "$addr:$port connected"
    
    fconfigure $sock -buffering line
    fileevent $sock readable [list handle_client $sock $addr $port]
}


proc handle_client {sock addr port} {

    # handle end of connection
    if {[eof $sock]} {
        close $sock
        return
    }

    # get the lines
    gets $sock line
    puts $line
    puts $sock "$line"

    # special handle to quit the loop
    if {$line eq "quit"} {
        puts $sock "Stopping VMD..."
        close $sock
        set ::exit_flag 1
        return
    }

    set result ""
    if {[catch {eval $line} result]} {
        puts $sock "ERROR: $result"
    } else {
        puts $sock "$addr:$port -> $result"
    }    
}

# loop until flag is set to 1
set ::exit_flag 0
vwait ::exit_flag
exit
