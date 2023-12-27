# Create a new simulation object
set ns [new Simulator]

# Create two nodes
set router [$ns node]
set high_priority_host [$ns node]
set low_priority_host [$ns node]

# Create links between nodes
$ns duplex-link $high_priority_host $router 10Mb 10ms DropTail
$ns duplex-link $low_priority_host $router 5Mb 20ms DropTail

# Set up high-priority traffic source and sink
set high_priority_source [new Application/Traffic/FTP]
$high_priority_source attach-agent $high_priority_host
set high_priority_sink [new Agent/TCPSink]
$ns attach-agent $high_priority_host $high_priority_sink
$ns connect $high_priority_source $high_priority_sink
$high_priority_source set type_ FTP
$high_priority_source set packetSize_ 1500
$high_priority_source set rate_ 2Mbps

# Set up low-priority traffic source and sink
set low_priority_source [new Application/Traffic/FTP]
$low_priority_source attach-agent $low_priority_host
set low_priority_sink [new Agent/TCPSink]
$ns attach-agent $low_priority_host $low_priority_sink
$ns connect $low_priority_source $low_priority_sink
$low_priority_source set type_ FTP
$low_priority_source set packetSize_ 1500
$low_priority_source set rate_ 1Mbps

# Implement QoS by setting different queue sizes
$ns queue-limit $high_priority_host $router 5
$ns queue-limit $low_priority_host $router 10

# Schedule events
$ns at 0.1 "$high_priority_source start"
$ns at 0.1 "$low_priority_source start"
$ns at 5.0 "$ns stop"

# Run the simulation
$ns run
