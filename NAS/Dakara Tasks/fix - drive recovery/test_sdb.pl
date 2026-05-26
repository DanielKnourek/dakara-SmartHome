[root@sysrescue ~]# smartctl -a /dev/sda
smartctl 7.5 2025-04-30 r5714 [x86_64-linux-6.12.43-1-lts] (local build)
Copyright (C) 2002-25, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Model Family:     WD Blue / Red / Green SSDs
Device Model:     WDC WDS240G2G0A-00JH30
Serial Number:    184215A016C5
LU WWN Device Id: 5 001b44 8b9b736b7
Firmware Version: UF450000
User Capacity:    240,065,183,744 bytes [240 GB]
Sector Size:      512 bytes logical/physical
Rotation Rate:    Solid State Device
Form Factor:      2.5 inches
TRIM Command:     Available, deterministic
Device is:        In smartctl database 7.5/5706
ATA Version is:   ACS-2 T13/2015-D revision 3
SATA Version is:  SATA 3.2, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Tue Nov 25 01:58:02 2025 CET
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: PASSED

General SMART Values:
Offline data collection status:  (0x00) Offline data collection activity
                                        was never started.
                                        Auto Offline Data Collection: Disabled.
Self-test execution status:      (  32) The self-test routine was interrupted
                                        by the host with a hard or soft reset.
Total time to complete Offline 
data collection:                (  120) seconds.
Offline data collection
capabilities:                    (0x15) SMART execute Offline immediate.
                                        No Auto Offline data collection support.
                                        Abort Offline collection upon new
                                        command.
                                        No Offline surface scan supported.
                                        Self-test supported.
                                        No Conveyance Self-test supported.
                                        No Selective Self-test supported.
SMART capabilities:            (0x0003) Saves SMART data before entering
                                        power-saving mode.
                                        Supports SMART auto save timer.
Error logging capability:        (0x01) Error logging supported.
                                        General Purpose Logging supported.
Short self-test routine 
recommended polling time:        (   2) minutes.
Extended self-test routine
recommended polling time:        (  42) minutes.

SMART Attributes Data Structure revision number: 1
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  5 Reallocated_Sector_Ct   0x0032   100   100   000    Old_age   Always       -       0
  9 Power_On_Hours          0x0032   100   100   000    Old_age   Always       -       36881
 12 Power_Cycle_Count       0x0032   100   100   000    Old_age   Always       -       924
165 Block_Erase_Count       0x0032   100   100   000    Old_age   Always       -       16578
166 Minimum_PE_Cycles_TLC   0x0032   100   100   ---    Old_age   Always       -       176
167 Max_Bad_Blocks_per_Die  0x0032   100   100   ---    Old_age   Always       -       0
168 Maximum_PE_Cycles_TLC   0x0032   100   100   ---    Old_age   Always       -       265
169 Total_Bad_Blocks        0x0032   100   100   ---    Old_age   Always       -       144
170 Grown_Bad_Blocks        0x0032   100   100   ---    Old_age   Always       -       0
171 Program_Fail_Count      0x0032   100   100   000    Old_age   Always       -       0
172 Erase_Fail_Count        0x0032   100   100   000    Old_age   Always       -       0
173 Average_PE_Cycles_TLC   0x0032   100   100   000    Old_age   Always       -       176
174 Unexpected_Power_Loss   0x0032   100   100   000    Old_age   Always       -       205
184 End-to-End_Error        0x0032   100   100   ---    Old_age   Always       -       0
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       0
188 Command_Timeout         0x0032   100   100   ---    Old_age   Always       -       0
194 Temperature_Celsius     0x0022   072   055   000    Old_age   Always       -       28 (Min/Max 9/55)
199 UDMA_CRC_Error_Count    0x0032   100   100   ---    Old_age   Always       -       0
230 Media_Wearout_Indicator 0x0032   100   100   000    Old_age   Always       -       0x2f2423142f24
232 Available_Reservd_Space 0x0033   100   100   005    Pre-fail  Always       -       100
233 NAND_GB_Written_TLC     0x0032   100   100   ---    Old_age   Always       -       44318
234 NAND_GB_Written_SLC     0x0032   100   100   000    Old_age   Always       -       126409
241 Host_Writes_GiB         0x0030   100   100   000    Old_age   Offline      -       27134
242 Host_Reads_GiB          0x0030   100   100   000    Old_age   Offline      -       7237
244 Temp_Throttle_Status    0x0032   000   100   ---    Old_age   Always       -       0

SMART Error Log Version: 1
No Errors Logged

SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short offline       Completed without error       00%     36762         -

Selective Self-tests/Logging not supported

The above only provides legacy SMART information - try 'smartctl -x' for more