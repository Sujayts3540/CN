# Create a wireless mesh network topology
set val(chan)   Channel/WirelessMesh
set val(prop)   Propagation/TwoRayGround
set val(netif)  Phy/WirelessPhy
set val(mac)    Mac/802_11
set val(ifq)    CMUPriQueue
set val(ll)     LL
set val(ant)    Antenna/OmniAntenna
set val(ifqlen) 50
set val(nn)     4
set val(rp)     DSDV
set val(x)      500
set val(y)      500
set val(stop)   10

# Create a mesh network
set ns_  [new Simulator]
set tracefd [open wireless-mesh.tr w]
$ns_ trace-all $tracefd
set namtrace [open wireless-mesh.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# Set up nodes
for {set i 0} {$i < $val(nn) } {incr i} {
    set node_($i) [$ns_ node]
    $node_($i) random-motion 0
    $node_($i) set X_ [expr rand()*$val(x)]
    $node_($i) set Y_ [expr rand()*$val(y)]
    $node_($i) set Z_ 0
}

# Set up mesh links
for {set i 0} {$i < $val(nn) } {incr i} {
    for {set j 0} {$j < $val(nn) } {incr j} {
        if {$i != $j} {
            set link_($i,$j) [$ns_ duplex-link $node_($i) $node_($j) $val(prop) $val(chan) $val(ifq) $val(ll) $val(mac)]
        }
    }
}

# Add traffic sources
set udp_ [new Agent/UDP]
$udp_ set packetSize_ 500

set cbr_ [new Application/Traffic/CBR]
$cbr_ set interval_ 0.1
$cbr_ attach-agent $udp_

# VoIP traffic
set voip_source_ [new Agent/UDP]
$voip_source_ set packetSize_ 160

set voip_traffic_ [new Application/Traffic/CBR]
$voip_traffic_ set interval_ 0.02
$voip_traffic_ attach-agent $voip_source_

# Video streaming traffic
set video_source_ [new Agent/UDP]
$video_source_ set packetSize_ 1000

set video_traffic_ [new Application/Traffic/CBR]
$video_traffic_ set interval_ 0.2
$video_traffic_ attach-agent $video_source_

# Attach agents to nodes
$ns_ attach-agent $node_(0) $udp_
$ns_ attach-agent $node_(1) $voip_source_
$ns_ attach-agent $node_(2) $video_source_
$ns_ attach-agent $node_(3) $udp_

# Set up routing
$ns_ at 0.1 "$node_(0) setdest 300 300 10"
$ns_ at 0.1 "$node_(1) setdest 100 100 10"
$ns_ at 0.1 "$node_(2) setdest 200 400 10"
$ns_ at 0.1 "$node_(3) setdest 400 200 10"

# Set up QoS mechanisms
$ns_ queue-limit $udp_ $val(ifqlen)
$ns_ queue-limit $voip_source_ $val(ifqlen)
$ns_ queue-limit $video_source_ $val(ifqlen)

# Run simulation
$ns_ run $val(stop)

# Close traces
$ns_ flush-trace
close $tracefd
close $namtrace
