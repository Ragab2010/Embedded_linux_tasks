#!/bin/bash

# Bash Script to Capture and Analyze Network Traffic

# Input: Path to the Wireshark pcap file from the first command-line argument
pcap_file="$1"

# Configuration file path
config_file="capture_config.conf"

# Function to capture network traffic
capture_traffic() {
    echo "Capture file not found. Starting a new capture..."

    # Create the pcap file and set permissions
    touch "$pcap_file"
    chmod 777 "$pcap_file"

    # Load configurations from the config file
    if [[ -f "$config_file" ]]; then
        source "$config_file"
    else
        echo "Configuration file not found. Using default settings."
        interface="wlp2s0"
        duration=20
        filter=""
    fi

    # Start capturing traffic using tshark
    if [[ -n "$filter" ]]; then
        sudo tshark -i "$interface" -a duration:"$duration" -w "$pcap_file" -f "$filter"
    else
        sudo tshark -i "$interface" -a duration:"$duration" -w "$pcap_file"
    fi

    echo "Capture complete. Saved to $pcap_file"
}

# Function to extract information from the pcap file
analyze_traffic() {
    # Total number of packets
    total_packets=$(tshark -r "$pcap_file" | wc -l)

    # Number of HTTP packets
    http_packets=$(tshark -r "$pcap_file" -Y "http" | wc -l)

    # Number of HTTPS/TLS packets
    tls_packets=$(tshark -r "$pcap_file" -Y "tls" | wc -l)

    # Top 5 Source IP Addresses
    top_source_ips=$(tshark -r "$pcap_file" -Y "http or tls" -T fields -e ip.src | sort | uniq -c | sort -nr | head -n 5)

    # Top 5 Destination IP Addresses
    top_dest_ips=$(tshark -r "$pcap_file" -Y "http or tls" -T fields -e ip.dst | sort | uniq -c | sort -nr | head -n 5)

    # Output analysis summary
    echo "----- Network Traffic Analysis Report -----"
    echo "1. Total Packets: $total_packets"
    echo "2. Protocols:"
    echo "   - HTTP: $http_packets packets"
    echo "   - HTTPS/TLS: $tls_packets packets"
    echo ""
    echo "3. Top 5 Source IP Addresses:"
    echo "$top_source_ips"
    echo ""
    echo "4. Top 5 Destination IP Addresses:"
    echo "$top_dest_ips"
    echo ""
    echo "----- End of Report -----"
}

# Main script execution
if [[ ! -f "$pcap_file" ]]; then
    # If the pcap file does not exist, create it, set permissions, and start capturing traffic
    capture_traffic
fi

# Run the analysis function
analyze_traffic
