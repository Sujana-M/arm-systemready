#!/bin/sh
# Copyright (c) 2022-2023, ARM Limited and Contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# Neither the name of ARM nor the names of its contributors may be used
# to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


# securityfs does not get automounted
#Already mounted on Yocto Linux
/bin/mount -t securityfs securityfs /sys/kernel/security

# give linux time to finish initializing disks
sleep 5

if [ "$(which mokutil)" != "" ]; then
  SB_STATE=`mokutil --sb-state`
  echo $SB_STATE
  if [ "$SB_STATE" = "SecureBoot enabled" ]; then
    echo "The system is in SecureBoot mode"
  else
    echo "WARNING: The System is not in SecureBoot mode"
  fi
fi

mkdir -p /mnt/acs_results/SIE/fwts

if [ -f  /bin/bbsr_fwts_tests.ini ]; then
  test_list=`cat /bin/bbsr_fwts_tests.ini | grep -v "^#" | awk '{print $1}' | xargs`
  echo "Test Executed are $test_list"
  fwts `echo $test_list` -f -r /mnt/acs_results/SIE/fwts/FWTSResults.log
fi

# run tpm2 tests
mkdir -p /mnt/acs_results/SIE/tpm2
if [ -f /sys/kernel/security/tpm0/binary_bios_measurements ]; then
  echo "TPM2: dumping PCRs and event log"
  cp /sys/kernel/security/tpm0/binary_bios_measurements /tmp
  tpm2_eventlog /tmp/binary_bios_measurements > /mnt/acs_results/SIE/tpm2/eventlog.log
  echo "  Event log: /mnt/acs_results/SIE/tpm2/eventlog.log"
  tpm2_pcrread > /mnt/acs_results/SIE/tpm2/pcr.log
  echo "  PCRs: /mnt/acs_results/SIE/tpm2/pcr.log"
  rm /tmp/binary_bios_measurements
  if grep -q "pcrs:" "/mnt/acs_results/SIE/tpm2/eventlog.log"; then
    echo "Comparing eventlog.log and pcr.log"
    #TPM2 logs event log v/s tpm.log check
    python3 /bin/verify_tpm_measurements.py /mnt/acs_results/SIE/tpm2/eventlog.log mnt/acs_results/SIE/tpm2/pcr.log > /mnt/acs_results/SIE/tpm2/eventlog_pcr_diff.log
  else
    echo "Info: PCR register entries not found at the end of event log, eventlog.log vs pcr.log, auto-comparison is not possible"
  fi 
else
   echo "TPM event log not found at /sys/kernel/security/tpm0/binary_bios_measurements"
fi

exit 0
