#!/bin/bash

# ───────────────────────────────────────────────
# STUDENT: s5
# STUDENTS NAME: Tomer Deri
# ID: 208660589
# PROGRAM CODE: nx212
# UNIT: TMagen773637
# LECTURER: Erel Regev
# ───────────────────────────────────────────────

# ───── Colors ─────
GREEN="\e[0;32m"
RED="\e[31m"
YELLOW="\e[33m"
NC="\e[0m" # Reset

# ───── Global Variables ─────
TOOL_DIR="$HOME/forensics_results"
mkdir -p "$TOOL_DIR"
LOG_FILE="$TOOL_DIR/analysis.log"

start_time=$(date +%s)

# ───── Root Check ─────
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}[!] This script must be run as root. Exiting.${NC}"
    exit 1
fi

# ───── Ask for Input File ─────
read -p "Enter the path to the memory or disk image file: " INPUT_FILE
if [[ ! -f "$INPUT_FILE" ]]; then
    echo -e "${RED}[!] File not found: $INPUT_FILE${NC}"
    exit 1
fi

# ───── Tool Installer ─────
function install_tools() {
    echo -e "${YELLOW}[+] Checking and installing necessary tools...${NC}"
    apt update &>/dev/null
    for tool in foremost bulk-extractor binwalk strings volatility; do
        if ! command -v $tool &>/dev/null; then
            echo -e "${YELLOW}[+] Installing: $tool${NC}"
            apt install -y $tool &>/dev/null
        fi
    done
}

# ───── Carving Data ─────
function carve_data() {
    echo -e "${GREEN}[+] Running data carving...${NC}"
    mkdir -p "$TOOL_DIR/carving"

    foremost -i "$INPUT_FILE" -o "$TOOL_DIR/carving/foremost" &>> "$LOG_FILE"
    bulk_extractor -o "$TOOL_DIR/carving/bulk" "$INPUT_FILE" &>> "$LOG_FILE"
    binwalk -e "$INPUT_FILE" -C "$TOOL_DIR/carving/binwalk" &>> "$LOG_FILE"
}

# ───── Search for Readable Data ─────
function extract_strings() {
    echo -e "${GREEN}[+] Extracting human-readable data...${NC}"
    strings "$INPUT_FILE" > "$TOOL_DIR/strings.txt"
    grep -Ei "pass|user|login|admin" "$TOOL_DIR/strings.txt" > "$TOOL_DIR/possible_credentials.txt"
}

# ───── Memory Analysis ─────
function analyze_memory() {
    echo -e "${GREEN}[+] Running Volatility on memory file...${NC}"
    mkdir -p "$TOOL_DIR/memory"

    profile=$(volatility -f "$INPUT_FILE" imageinfo 2>/dev/null | grep 'Suggested Profile' | awk -F': ' '{print $2}' | cut -d',' -f1)
    
    if [[ -z "$profile" ]]; then
        echo -e "${RED}[!] Could not identify memory profile.${NC}"
        return
    fi

    echo "[+] Profile detected: $profile" | tee -a "$LOG_FILE"

    volatility -f "$INPUT_FILE" --profile="$profile" pslist > "$TOOL_DIR/memory/pslist.txt"
    volatility -f "$INPUT_FILE" --profile="$profile" netscan > "$TOOL_DIR/memory/netscan.txt"
    volatility -f "$INPUT_FILE" --profile="$profile" printkey -K "Software\\Microsoft\\Windows\\CurrentVersion\\Run" > "$TOOL_DIR/memory/registry.txt"
}

# ───── Network Traffic Detection ─────
function detect_traffic() {
    echo -e "${GREEN}[+] Checking for possible .pcap files...${NC}"
    find "$TOOL_DIR/carving" -name "*.pcap" -exec du -h {} \; > "$TOOL_DIR/pcap_summary.txt"
    if [[ -s "$TOOL_DIR/pcap_summary.txt" ]]; then
        echo "[+] .pcap file(s) detected:"
        cat "$TOOL_DIR/pcap_summary.txt"
    else
        echo "[-] No .pcap files detected." >> "$LOG_FILE"
    fi
}

# ───── Summary and Cleanup ─────
function generate_report() {
    echo -e "${YELLOW}[+] Generating report...${NC}"
    report="$TOOL_DIR/report.txt"
    echo "========== Forensics Report ==========" > "$report"
    echo "Target File: $INPUT_FILE" >> "$report"
    echo "Analysis Time: $(date)" >> "$report"
    echo "Extracted Files Count: $(find "$TOOL_DIR" -type f | wc -l)" >> "$report"
    echo "Profile Used: $profile" >> "$report"
    echo "======================================" >> "$report"
    
    zip -r "$TOOL_DIR/forensics_results.zip" "$TOOL_DIR"/* &>/dev/null
    echo "[+] All results zipped to: $TOOL_DIR/forensics_results.zip"
}

# ───── Run Everything ─────
install_tools
carve_data
extract_strings

file_type=$(file "$INPUT_FILE")
if echo "$file_type" | grep -qi "memory"; then
    analyze_memory
fi

detect_traffic
generate_report

end_time=$(date +%s)
runtime=$((end_time - start_time))
echo -e "${GREEN}Analysis completed in ${runtime} seconds.${NC}"
