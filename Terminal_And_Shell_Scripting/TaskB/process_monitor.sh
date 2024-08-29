#!/usr/bin/bash -i

# Source the configuration file if it exists
if [[ -f process_monitor.conf ]]; then
    source process_monitor.conf
else
    echo "Warning: Configuration file 'process_monitor.conf' not found. Using default settings."
    UPDATE_INTERVAL=5
    CPU_ALERT_THRESHOLD=90
    MEMORY_ALERT_THRESHOLD=80
fi

# Load configuration from file if it exists
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

############## List Running Processes ##############
list_processes() {
    echo -e "PID\tUSER\t%CPU\t%MEM\tCOMMAND"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 20
}

############## Process Information ##############
process_info() {
    local pid=$1
    if [[ -z "$pid" ]]; then
        echo "Error: PID not provided."
        return 1
    fi

    if ! ps -p "$pid" > /dev/null; then # redirect  pid  for > /dev/null to discarding it if not exist
        echo "Error: No such process with PID $pid."
        return 1
    fi

    ps -p "$pid" -o pid,ppid,user,%cpu,%mem,s,time,comm
}

############## Kill a Process ##############
kill_process() {
    local pid=$1
    if [[ -z "$pid" ]]; then
        echo "Error: PID not provided."
        return 1
    fi

    if ! ps -p "$pid" > /dev/null; then
        echo "Error: No such process with PID $pid."
        return 1
    fi

    kill "$pid"
    echo "Process $pid terminated."
    echo "$(date): Process $pid terminated." >> process_monitor.log
}

############## Process Statistics ##############
process_statistics() {
    total_procs=$(ps aux | wc -l)
    total_memory=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    cpu_load=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    echo  "Total Processes: $total_procs"
    echo  "Memory Usage: $total_memory%"
    echo  "CPU Load: $cpu_load%"
}

############## Real-time Monitoring ##############
real_time_monitoring() {
    local stop_flag=0
    local UPDATE_INTERVAL=2  # Set your desired update interval here

    # Function to handle key press for stopping
    check_stop_key() {
        # Check for a key press
        read -t "$UPDATE_INTERVAL" -n 1 key
        if [[ $key == "q" || $key == "Q" ]]; then
            stop_flag=1
        fi
    }

    while [[ $stop_flag -eq 0 ]]; do
        clear
        list_processes
        echo "Press [q] to stop."
        check_stop_key
    done

    # Final message
    echo "Real-time monitoring stopped."
}

############## Search and Filter ##############
search_processes() {
    local search_term=$1
    if [[ -z "$search_term" ]]; then
        echo "Error: Search term not provided."
        return 1
    fi

    ps aux | grep "$search_term" | grep -v grep
}

############## Resource Usage Alerts ##############
############## Resource Usage Alerts ##############


#         # cpu_mem_usage=$(ps -p "$pid" -o %cpu,%mem --no-headers)
#         # echo "cpu_mem_usage=$cpu_mem_usage"

#         # # Using parameter expansion to remove the trailing '%'
#         # cpu_usage=$(echo "$cpu_mem_usage" | awk '{print $1}')
#         # mem_usage=$(echo "$cpu_mem_usage" | awk '{print $2}')

#         # cpu_usage=${cpu_usage%\%}
#         # mem_usage=${mem_usage%\%}

#         # echo "CPU Usage: $cpu_usage"
#         # echo "Memory Usage: $mem_usage"


#         # # Trim leading and trailing spaces using bash parameter expansion
#         # cpu_mem_usage="${cpu_mem_usage#"${cpu_mem_usage%%[![:space:]]*}"}"  # Remove leading spaces
#         # cpu_mem_usage="${cpu_mem_usage%"${cpu_mem_usage##*[![:space:]]}"}"  # Remove trailing spaces

#         # # Extract and remove the trailing % sign
#         # cpu_usage=${cpu_mem_usage%% *}
#         # cpu_usage=${cpu_usage%\%}

#         # mem_usage=${cpu_mem_usage#* }
#         # mem_usage=${mem_usage%\%}

#         # echo "CPU Usage: $cpu_usage"
#         # echo "Memory Usage: $mem_usage"

# ################################
#         # # Extract and remove the trailing % sign
#         # cpu_usage=${cpu_mem_usage%% *}
#         # cpu_usage=${cpu_usage%\%}

#         # mem_usage=${cpu_mem_usage#* }
#         # mem_usage=${mem_usage%\%}

#         # echo "CPU Usage: $cpu_usage"
#         # echo "Memory Usage: $mem_usage"

resource_alerts() {
    if [[ "$#" -ne 1 ]]; then
        echo "Usage: resource_alerts <PID>"
        return 1
    fi

    local pid="$1"
    local cpu_mem_usage
    local cpu_usage
    local mem_usage

    # Check if the process with the given PID exists
    if ! ps -p "$pid" > /dev/null; then
        echo "Error: No such process with PID $pid."
        return 1
    fi

    while true; do
        # Get CPU and memory usage
        cpu_mem_usage=$(ps -p "$pid" -o %cpu,%mem --no-headers)
        echo "cpu_mem_usage='$cpu_mem_usage'"

        # Using parameter expansion to remove the trailing '%'
        cpu_usage=$(echo "$cpu_mem_usage" | awk '{print $1}')
        mem_usage=$(echo "$cpu_mem_usage" | awk '{print $2}')

        cpu_usage=${cpu_usage%\%}
        mem_usage=${mem_usage%\%}

        echo "cpu_usage='$cpu_usage'"
        echo "mem_usage='$mem_usage'"

        # Check if values are correctly extracted
        if [[ -z "$cpu_usage" || -z "$mem_usage" ]]; then
            echo "Error: Failed to extract CPU or memory usage for PID $pid."
            sleep "$UPDATE_INTERVAL"
            continue
        fi

        # Remove the trailing percent signs
        cpu_usage=${cpu_usage%.*}
        mem_usage=${mem_usage%.*}

        echo "Stripped cpu_usage='$cpu_usage'"
        echo "Stripped mem_usage='$mem_usage'"

        # Check for valid numeric values before comparing
        if ! [[ "$cpu_usage" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! [[ "$mem_usage" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
            echo "Error: Invalid CPU or memory usage value for PID $pid."
            sleep "$UPDATE_INTERVAL"
            continue
        fi

        # Check against thresholds using bc for floating-point comparisons
        cpu_usage_alert=$(echo "$cpu_usage > $CPU_ALERT_THRESHOLD" | bc -l)
        mem_usage_alert=$(echo "$mem_usage > $MEMORY_ALERT_THRESHOLD" | bc -l)

        if (( $(echo "$cpu_usage_alert" | bc -l) == 1 )) || (( $(echo "$mem_usage_alert" | bc -l) == 1 )); then
            echo "Alert: Process $pid is using high resources: CPU $cpu_usage%, Memory $mem_usage%"
            echo "$(date): Alert for process $pid - CPU: $cpu_usage%, Memory: $mem_usage%" >> process_monitor.log
        fi

        sleep "$UPDATE_INTERVAL"
    done
}


############## Interactive Menu ##############
interactive_menu() {
    while true; do
        echo -e "\nProcess Monitor Menu:"
        echo "1. List Running Processes"
        echo "2. Process Information"
        echo "3. Kill a Process"
        echo "4. Process Statistics"
        echo "5. Real-time Monitoring"
        echo "6. Search and Filter"
        echo "7. Resource Usage Alerts"
        echo "8. Exit"

        read -p "Choose an option: " option

        case $option in
            1)
                list_processes
                ;;
            2)
                read -p "Enter PID: " pid
                process_info "$pid"
                ;;
            3)
                read -p "Enter PID: " pid
                kill_process "$pid"
                ;;
            4)
                process_statistics
                ;;
            5)
                real_time_monitoring
                ;;
            6)
                read -p "Enter search term: " search_term
                search_processes "$search_term"
                ;;
            7)
                read -p "Enter PID: " pid
                resource_alerts "$pid"
                ;;
            8)
                #exit 0
                break
                ;;
            *)
                echo "Invalid option. Please choose a valid number."
                ;;
        esac
    done
}

############## Main Execution ##############
#interactive_menu
