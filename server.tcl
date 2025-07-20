menu main off
menu graphics off
menu color off
menu tkcon off

set server [socket -server accept_client 12345]
puts "Listening cl-vmd on port 12345"

proc accept_client {sock addr port} {
    puts "cl-vmd client connected @ $addr:$port"
    fconfigure $sock -buffering line
    fileevent $sock readable [list handle_client $sock $addr $port]
}


proc handle_client {sock addr port} {
    if {[eof $sock]} {
        close $sock
        puts "Closed connection"
        return
    }

    gets $sock line
    puts "$addr:$port -> $line"

    if {$line eq "quit"} {
        puts $sock "Stopping vmd..."
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

set ::exit_flag 0
vwait ::exit_flag
exit
