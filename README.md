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

# 6. Report Generation
After all analysis is complete, the script:
- Generates a summary report with:
- Input file analyzed
- Date
- Number of extracted files
- Volatility profile used
- Compresses all output into a single ZIP archive
- Displays a final completion message

---

## Execution Flow
	1.	Validate root access
	2.	Ask for the disk/memory image path
	3.	Install missing tools
	4.	Perform data carving
	5.	Extract strings and detect credentials
	6.	Run memory analysis (if applicable)
	7.	Detect PCAP files
	8.	Generate final report
	9.	Create ZIP package
	10.	Display runtime summary and exit

---

## Output Structure
Typical output includes:
- carved/ – carved files from foremost, bulk-extractor, binwalk
- strings.txt – extracted readable strings
- possible_credentials.txt – filtered credential-like strings
- memory_analysis/ – volatility output (if memory dump)
- analysis.log – full log of script actions
- report.txt – final summary
- <timestamp>.zip – compressed archive of all results

---

## ⚠️ Legal Notice
This script is intended for educational and authorized forensic use only.
Do not analyze files you do not have the right to access.

---

## Author
Tomer Dery












