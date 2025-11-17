# Windows-Forensics-Analysis-Script
This project is a Bash-based automation tool for performing forensic analysis on disk or memory image files on a Linux system.
It installs necessary tools, performs data carving, extracts readable text, analyzes memory with Volatility, detects PCAP files, and generates a complete forensic report.

--- 

## Overview
This script streamlines forensic work by automating:
- File carving
- Artifact extraction
- Credential hunting
- Memory analysis
- PCAP detection
- Summary report generation
- ZIP archiving of all results

It is ideal for training, labs, and structured forensic exercises.

---

## Features

# 1. Tool Installation
Automatically installs and verifies required forensic tools:
- foremost
- bulk-extractor
- binwalk
- strings
- volatility

This ensures the environment is fully prepared before analysis begins.

# 2. Data Carving 
Uses three industry-standard utilities to extract artifacts:
- foremost – general file carving
- bulk-extractor – extracts emails, URLs, phone numbers, network artifacts
- binwalk – extracts embedded files or firmware contents

All results are organized in dedicated subfolders and logged into analysis.log. 

# 3. Strings Extraction
- Extracts all ASCII-readable strings from the image
- Saves results to strings.txt
- Searches for potential credentials using common patterns (pass, user, admin, etc.)
- Saves suspicious findings to possible_credentials.txt 

# 4. Memory Analysis (Volatility)
If the input file is a memory dump:
- Detects the correct memory profile
- Extracts:
  - Running processes (pslist)
  - Network connections (netscan)
  - Registry autostart keys (printkey)

Results stored inside the memory_analysis/ directory.

# 5. PCAP Detection
Searches the carved output for .pcap files:
- Logs their size and location
- Reports findings to the user
- Logs a message if none are found

# 6. Searches the carved output for .pcap files:
	•	Logs their size and location
	•	Reports findings to the user
	•	Logs a message if none are found










