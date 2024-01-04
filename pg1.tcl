# Create a simple simulation scenario
set ns [new Simulator]

# Define simulation parameters
set node_num 3
set bs_range 100 ;# Base station range

# Create nodes
for {set i 0} {$i < $node_num} {incr i} {
    set node($i) [$ns node]
}

# Create a base station
set bs [$ns node]
$bs shape hexagon
$bs color red
$bs label "Base Station"

# Set up links between nodes and the base station
for {set i 0} {$i < $node_num} {incr i} {
    $ns duplex-link $bs $node($i) 1Mbps 10ms DropTail
}

# Define a simple MAC layer for GSM
$ns duplex-link-op $bs $node(0) orient right-down
$ns duplex-link-op $bs $node(1) orient right
$ns duplex-link-op $bs $node(2) orient right-up

# Set the propagation delay for wireless links
for {set i 0} {$i < $node_num} {incr i} {
    $ns at 0.0 "$ns rtproto DV $node($i) 1"
}

# Define the movement of mobile stations (simple linear movement)
for {set i 0} {$i < $node_num} {incr i} {
    $ns at 0.0 "$node($i) setdest [expr rand()*$bs_range] [expr rand()*$bs_range] 10.0"
    $ns at 5.0 "$node($i) setdest [expr rand()*$bs_range] [expr rand()*$bs_range] 10.0"
}

# Define simulation duration
$ns at 15.0 "$ns stop"

# Run the simulation
$ns run
