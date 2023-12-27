# Create a simple network topology
set ns [new Simulator]

set node0 [$ns node]
set node1 [$ns node]

$ns duplex-link $node0 $node1 10Mb 10ms DropTail

# Enable QoS on the link
$ns queue-limit $node0 $node1 10
$ns queue-type $node0 $node1 DropTail
$ns drop-tail-prio $node0 $node1 0

# Set different priority levels for traffic
$ns set-priority $node0 $node1 0 1 2

# Create traffic flows with different priorities
set tcp0 [new Agent/TCP]
$ns attach-agent $node0 $tcp0

set tcp1 [new Agent/TCP]
$ns attach-agent $node1 $tcp1

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns connect $ftp0 $node1 0

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns connect $ftp1 $node0 0

# Schedule events and run the simulation
$ns at 0.1 "$ftp0 start"
$ns at 0.2 "$ftp1 start"

$ns run
