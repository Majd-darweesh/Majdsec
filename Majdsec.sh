#!/bin/bash

# Basic Analysis Tool - Majd Darwish

# Clear the screen
clear

# Default values
threshold=100
alert_email="admin@domain.com"
log_file="analysis_log.txt"
report_file="report.html"
css_file="report.css"
enable_ddos=false
enable_access=false
enable_log=true

# Display header and tool details
echo "*****************************************************************"
echo "  ██████████████████████████████████████████████████████"
echo "  ████╗ ██╗   ██╗██████╗ ███████╗██╗  ██╗███████╗███████╗"
echo "  ██╔══██╗██║   ██║██╔══██╗██╔════╝██║  ██║██╔════╝██╔════╝"
echo "  ██████╔╝██║   ██║██████╔╝███████╗███████║███████╗███████╗"
echo "  ██╔══██╗██║   ██║██╔══██╗╚════██║██╔══██║╚════██║╚════██║"
echo "  ██████╔╝╚██████╔╝██████╔╝███████║██║  ██║███████║███████║"
echo "  ╚════╝    ╚═════╝ ╚════╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝"
echo "*****************************************************************"
echo "                     Basic Analysis Tool v2.0                   "
echo "*****************************************************************"
echo "         By Majd Darwish - Cybersecurity Specialist              "
echo "*****************************************************************"
echo "Tool Purpose:"
echo "- This tool was designed to help SOC teams detect network anomalies."
echo "- It identifies potential DDoS attacks and unauthorized access attempts."
echo "- Generates a visually appealing HTML report for analysis."
echo "*****************************************************************"

# Menu for user options
function show_menu() {
    echo "Choose an option:"
    echo "1) Help"
    echo "2) Enable DDoS detection"
    echo "3) Enable unauthorized access detection"
    echo "4) Generate HTML report"
    echo "5) Exit"
}

# Function to display help
function show_help() {
    echo "*****************************************************************"
    echo "Help:"
    echo "1) Enable DDoS detection: Monitors for high packet rates from single IPs."
    echo "2) Enable unauthorized access detection: Monitors SSH, Telnet, RDP ports."
    echo "3) Generate HTML report: Creates a detailed report of detected events."
    echo "*****************************************************************"
}

# Initialize HTML and CSS report
function initialize_report() {
    cat <<EOL > $css_file
body { font-family: Arial, sans-serif; margin: 20px; }
h1, h2 { color: #333; }
table { border-collapse: collapse; width: 100%; margin-top: 20px; }
th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
th { background-color: #f2f2f2; }
EOL

    cat <<EOL > $report_file
<!DOCTYPE html>
<html>
<head>
    <title>Basic Analysis Tool Report</title>
    <link rel="stylesheet" type="text/css" href="$css_file">
</head>
<body>
    <h1>Basic Analysis Tool Report</h1>
    <h2>Report Generated on $(date)</h2>
    <table>
        <tr>
            <th>IP Address</th>
            <th>Access Attempts</th>
        </tr>
EOL
}

# Finalize HTML report
function finalize_report() {
    echo "    </table>" >> $report_file
    echo "</body></html>" >> $report_file
    echo "[INFO] Report saved as $report_file"
}

# Sniff packets using tcpdump
function analyze_packets() {
    echo "[INFO] Starting packet analysis..."
    declare -A ip_counter
    tcpdump -i eth0 -n -l | while read line
    do
        # Extract the source IP
        src_ip=$(echo $line | awk '{print $3}' | cut -d '.' -f 1-4)
        
        # Count requests from each IP
        ip_counter[$src_ip]=$((ip_counter[$src_ip] + 1))

        # Detect DDoS if enabled
        if [[ "$enable_ddos" == "true" && ${ip_counter[$src_ip]} -ge $threshold ]]; then
            echo "[ALERT] Potential DDoS attack detected from IP: $src_ip"
            echo "<tr><td>$src_ip</td><td>${ip_counter[$src_ip]}</td></tr>" >> $report_file
        fi
    done
}

# Main program loop
while true; do
    show_menu
    read -p "Enter your choice: " choice
    case $choice in
        1) show_help ;;
        2) 
            enable_ddos=true
            echo "[INFO] DDoS detection enabled."
            ;;
        3) 
            enable_access=true
            echo "[INFO] Unauthorized access detection enabled."
            ;;
        4) 
            initialize_report
            analyze_packets
            finalize_report
            ;;
        5) 
            echo "[INFO] Exiting tool. Thank you!"
            break
            ;;
        *) 
            echo "[ERROR] Invalid option. Please try again."
            ;;
    esac
done
