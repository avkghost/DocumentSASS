# Set up compiler, just compile a .ptx for the lowest arch possible. It does not matter as we are interested in SASS.
CC=cc
NVCC=/usr/local/cuda/bin/nvcc
NVDISASM=/usr/local/cuda/bin/nvdisasm
PYTHON=python3

architectures=sm_50 sm_52 sm_53 sm_60 sm_61 sm_62 sm_70 sm_72 sm_75 sm_80 sm_86 sm_90

targets = $(architectures:=_instructions.txt) $(architectures:=_latencies.txt)

.PRECIOUS: sm_86_intercept.txt sm_61_intercept.txt sm_50_intercept.txt sm_53_intercept.txt sm_72_intercept.txt sm_90_intercept.txt sm_80_intercept.txt sm_60_intercept.txt sm_75_intercept.txt intercept.so sm_62_intercept.txt sm_70_intercept.txt sm_52_intercept.txt

all: $(targets)

#clean:
	

# Generate the SASS versions.
%.cubin: example.cu
	$(NVCC) -o $@ -arch=$(basename $@) -cubin $<

%.so: %.c
	$(CC) -fPIC -shared -o $@ $< -ldl

# Not sure if the OMP things are needed, same with the flushing of stdout. We pipe it through strings to get only readable parts.
%_intercept.txt: %.cubin intercept.so
	OMP_NUM_THREADS=1 OMP_THREAD_LIMIT=1 LD_PRELOAD=./intercept.so $(NVDISASM) $< | strings -n 1 > $@

%_instructions.txt %_latencies.txt: %_intercept.txt
	$(PYTHON) funnel.py $<





