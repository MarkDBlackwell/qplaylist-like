#!/bin/sh
# Copyright (C) 2024 Mark D. Blackwell. All rights reserved. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

# Examples:

## ./report.sh 2024-mar-1
## ./report.sh 2024-mar-1 2024-mar-18

ruby lib/report_system/main.rb $1 $2
