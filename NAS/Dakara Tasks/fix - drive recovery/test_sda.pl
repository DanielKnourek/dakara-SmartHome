[root@sysrescue ~]# smartctl -a /dev/sdb
smartctl 7.5 2025-04-30 r5714 [x86_64-linux-6.12.43-1-lts] (local build)
Copyright (C) 2002-25, Bruce Allen, Christian Franke, www.smartmontools.org

=== START OF INFORMATION SECTION ===
Model Family:     SK hynix SATA SSDs
Device Model:     SK hynix SC311 SATA 256GB
Serial Number:    MD8AN40711490A335
Firmware Version: 70000P10
User Capacity:    256,060,514,304 bytes [256 GB]
Sector Sizes:     512 bytes logical, 4096 bytes physical
Rotation Rate:    Solid State Device
Form Factor:      M.2
TRIM Command:     Available, deterministic, zeroed
Device is:        In smartctl database 7.5/5706
ATA Version is:   ACS-3 (minor revision not indicated)
SATA Version is:  SATA 3.2, 6.0 Gb/s (current: 6.0 Gb/s)
Local Time is:    Tue Nov 25 01:51:15 2025 CET
SMART support is: Available - device has SMART capability.
SMART support is: Enabled

=== START OF READ SMART DATA SECTION ===
SMART overall-health self-assessment test result: FAILED!
Drive failure expected in less than 24 hours. SAVE ALL DATA.
No failed Attributes found.

General SMART Values:
Offline data collection status:  (0x03) Offline data collection activity
                                        is in progress.
                                        Auto Offline Data Collection: Disabled.
Self-test execution status:      (   0) The previous self-test routine completed
                                        without error or no self-test has ever 
                                        been run.
Total time to complete Offline 
data collection:                (  110) seconds.
Offline data collection
capabilities:                    (0x51) SMART execute Offline immediate.
                                        No Auto Offline data collection support.
                                        Suspend Offline collection upon new
                                        command.
                                        No Offline surface scan supported.
                                        Self-test supported.
                                        No Conveyance Self-test supported.
                                        Selective Self-test supported.
SMART capabilities:            (0x0002) Does not save SMART data before
                                        entering power-saving mode.
                                        Supports SMART auto save timer.
Error logging capability:        (0x01) Error logging supported.
                                        General Purpose Logging supported.
Short self-test routine 
recommended polling time:        (   2) minutes.
Extended self-test routine
recommended polling time:        (  40) minutes.
SCT capabilities:              (0x003d) SCT Status supported.
                                        SCT Error Recovery Control supported.
                                        SCT Feature Control supported.
                                        SCT Data Table supported.

SMART Attributes Data Structure revision number: 0
Vendor Specific SMART Attributes with Thresholds:
ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
  1 Raw_Read_Error_Rate     0x000f   166   166   006    Pre-fail  Always       -       0
  5 Retired_Block_Count     0x0032   253   253   036    Old_age   Always       -       0
  9 Power_On_Hours          0x0032   059   059   000    Old_age   Always       -       37059
 12 Power_Cycle_Count       0x0032   100   100   020    Old_age   Always       -       2127
100 Total_Erase_Count       0x0032   097   097   000    Old_age   Always       -       139126312
168 Min_Erase_Count         0x0032   001   001   000    Old_age   Always       -       4896
169 Max_Erase_Count         0x0032   001   001   000    Old_age   Always       -       4961
174 Unexpect_Power_Loss_Ct  0x0030   100   100   000    Old_age   Offline      -       58
175 Program_Fail_Count_Chip 0x0032   253   253   000    Old_age   Always       -       0
176 Unused_Rsvd_Blk_Cnt_Tot 0x0032   253   253   000    Old_age   Always       -       0
177 Wear_Leveling_Count     0x0032   001   001   000    Old_age   Always       -       4929
178 Used_Rsvd_Blk_Cnt_Chip  0x0032   253   253   000    Old_age   Always       -       0
179 Used_Rsvd_Blk_Cnt_Tot   0x0032   253   253   000    Old_age   Always       -       0
180 Erase_Fail_Count        0x0032   100   100   000    Old_age   Always       -       620
181 Non4k_Aligned_Access    0x0032   253   253   000    Old_age   Always       -       0
182 Erase_Fail_Count_Total  0x0032   253   253   000    Old_age   Always       -       0
184 End-to-End_Error        0x0032   100   100   000    Old_age   Always       -       45
187 Reported_Uncorrect      0x0032   100   100   000    Old_age   Always       -       34
188 Command_Timeout         0x0032   100   100   000    Old_age   Always       -       267
194 Temperature_Celsius     0x0002   029   016   000    Old_age   Always       -       29 (Min/Max 16/68)
195 Hardware_ECC_Recovered  0x0032   253   054   000    Old_age   Always       -       0
196 Reallocated_Event_Count 0x0032   253   253   036    Old_age   Always       -       0
198 Offline_Uncorrectable   0x0032   253   253   000    Old_age   Always       -       0
199 UDMA_CRC_Error_Count    0x0032   253   253   000    Old_age   Always       -       0
204 Soft_ECC_Correction     0x000e   100   001   000    Old_age   Always       -       10406
212 Phy_Error_Count         0x0032   100   100   000    Old_age   Always       -       16436556
233 Media_Wearout_Indicator 0x0032   001   001   000    Old_age   Always       -       4294967068
234 Unknown_SK_hynix_Attrib 0x0032   100   100   000    Old_age   Always       -       2564290402000
241 Total_Writes_GB         0x0032   100   100   000    Old_age   Always       -       266279883664
242 Total_Reads_GB          0x0032   100   100   000    Old_age   Always       -       63009239432

SMART Error Log Version: 1
ATA Error Count: 43 (device log contains only the most recent five errors)
        CR = Command Register [HEX]
        FR = Features Register [HEX]
        SC = Sector Count Register [HEX]
        SN = Sector Number Register [HEX]
        CL = Cylinder Low Register [HEX]
        CH = Cylinder High Register [HEX]
        DH = Device/Head Register [HEX]
        DC = Device Command Register [HEX]
        ER = Error register [HEX]
        ST = Status register [HEX]
Powered_Up_Time is measured from power on, and printed as
DDd+hh:mm:SS.sss where DD=days, hh=hours, mm=minutes,
SS=sec, and sss=millisec. It "wraps" after 49.710 days.

Error 43 occurred at disk power-on lifetime: 37059 hours (1544 days + 3 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  04 41 00 00 00 00 00  Error: ABRT at LBA = 0x00000000 = 0

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  61 08 78 00 00 02 40 40      11:55:01.290  WRITE FPDMA QUEUED
  61 00 70 00 00 00 40 40      11:55:01.290  WRITE FPDMA QUEUED
  61 b0 68 00 2e cf 40 40      11:55:01.290  WRITE FPDMA QUEUED
  61 08 60 00 2a cf 40 40      11:55:01.290  WRITE FPDMA QUEUED
  61 08 58 00 28 cf 40 40      11:55:01.290  WRITE FPDMA QUEUED

Error 42 occurred at disk power-on lifetime: 37059 hours (1544 days + 3 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  04 41 00 00 00 00 00  Error: ABRT at LBA = 0x00000000 = 0

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  61 08 48 00 00 02 40 40      11:55:01.200  WRITE FPDMA QUEUED
  61 00 40 00 00 00 40 40      11:55:01.200  WRITE FPDMA QUEUED
  61 b0 38 00 2e cf 40 40      11:55:01.200  WRITE FPDMA QUEUED
  61 08 30 00 2a cf 40 40      11:55:01.200  WRITE FPDMA QUEUED
  61 08 28 00 28 cf 40 40      11:55:01.200  WRITE FPDMA QUEUED

Error 41 occurred at disk power-on lifetime: 37059 hours (1544 days + 3 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  04 41 00 00 00 00 00  Error: ABRT at LBA = 0x00000000 = 0

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  61 08 00 a0 26 cf 40 40      11:55:01.110  WRITE FPDMA QUEUED
  61 08 f0 00 00 02 40 40      11:55:01.110  WRITE FPDMA QUEUED
  61 00 b8 00 00 00 40 40      11:55:01.110  WRITE FPDMA QUEUED
  61 b0 18 00 2e cf 40 40      11:55:01.110  WRITE FPDMA QUEUED
  61 08 10 00 2a cf 40 40      11:55:01.110  WRITE FPDMA QUEUED

Error 40 occurred at disk power-on lifetime: 37059 hours (1544 days + 3 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  04 41 00 00 00 00 00  Error: ABRT at LBA = 0x00000000 = 0

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  61 08 c8 00 00 02 40 40      11:55:01.000  WRITE FPDMA QUEUED
  61 00 c0 00 00 00 40 40      11:55:01.000  WRITE FPDMA QUEUED
  60 08 b8 a0 26 cf 40 40      11:55:01.000  READ FPDMA QUEUED
  ea 00 00 00 00 00 a0 a0      11:55:01.000  FLUSH CACHE EXT
  60 98 30 68 30 cf 40 40      11:54:46.200  READ FPDMA QUEUED

Error 39 occurred at disk power-on lifetime: 37059 hours (1544 days + 3 hours)
  When the command that caused the error occurred, the device was active or idle.

  After command completion occurred, registers were:
  ER ST SC SN CL CH DH
  -- -- -- -- -- -- --
  04 41 00 00 00 00 00  Error: ABRT at LBA = 0x00000000 = 0

  Commands leading to the command that caused the error were:
  CR FR SC SN CL CH DH DC   Powered_Up_Time  Command/Feature_Name
  -- -- -- -- -- -- -- --  ----------------  --------------------
  61 28 b0 00 00 00 40 40      11:47:18.340  WRITE FPDMA QUEUED
  61 28 a8 88 32 cf 40 40      11:47:18.340  WRITE FPDMA QUEUED
  47 00 01 30 08 00 a0 a0      11:47:18.340  READ LOG DMA EXT
  47 00 01 30 00 00 a0 a0      11:47:18.340  READ LOG DMA EXT
  47 00 01 00 00 00 a0 a0      11:47:18.340  READ LOG DMA EXT

SMART Self-test log structure revision number 1
Num  Test_Description    Status                  Remaining  LifeTime(hours)  LBA_of_first_error
# 1  Short offline       Completed without error       00%      7635         -

Warning! SMART Selective Self-Test Log Structure error: invalid SMART checksum.
SMART Selective self-test log data structure revision number 0
Note: revision number not 1 implies that no selective self-test has ever been run
 SPAN  MIN_LBA  MAX_LBA  CURRENT_TEST_STATUS
    1        0        0  Not_testing
    2        0        0  Not_testing
    3        0        0  Not_testing
    4        0        0  Not_testing
    5        0        0  Not_testing
Selective self-test flags (0x0):
  After scanning selected spans, do NOT read-scan remainder of disk.
If Selective self-test is pending on power-up, resume after 0 minute delay.

The above only provides legacy SMART information - try 'smartctl -x' for more