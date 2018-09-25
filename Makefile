#############################################################
# Compile options 	                               #
#-----------------------------------------------------------#

#----------------------------------------------#
# Library PATH				             #
#----------------------------------------------#
CUDA_TOOLKIT_PATH ?= /usr/local/cuda/
BOOST_PATH ?= /usr/local/

#----------------------------------------------#
# GPU environment settings               #
#----------------------------------------------#

GPU_ARCH=compute_60
GPU_CODE=sm_60

#----------------------------------------------#
# Mode               		          #
#----------------------------------------------#

MODE    := Release
 # (If you use Debug mode, please set the value as Debug)

#----------------------------------------------#
# Profile mode                           #
#----------------------------------------------#

PROFILE    := Yes
#-----------------------------------------------------------------------------------------#


USE_GPU    := Yes

NVCC=$(CUDA_TOOLKIT_PATH)/bin/nvcc
CC=$(NVCC)
CXX=$(NVCC)

INCLUDES  += -I$(BOOST_PATH)/include -I./ext/cub-1.3.2

CFLAGS= 
CXXFLAGS= 
NVCCFLAGS= 

LDLIBS = -L$(BOOST_PATH)/lib
LDFLAGS =  -lm -lboost_thread -lboost_system --cudart static 

EXECUTABLE = 
ifeq ($(USE_GPU),Yes)
	CFLAGS   += -DGPU -gencode arch=$(GPU_ARCH),code=$(GPU_CODE) 
	CXXFLAGS += -DGPU -gencode arch=$(GPU_ARCH),code=$(GPU_CODE) 
	NVCCFLAGS  += -DGPU -gencode arch=$(GPU_ARCH),code=$(GPU_CODE)
	LDFLAGS += -gencode arch=$(GPU_ARCH),code=$(GPU_CODE)
	EXECUTABLE = ghostz-gpu
else
	EXECUTABLE = ghostz
endif

ifeq ($(MODE),Release)
	CFLAGS += -O3
	CXXFLAGS   += -O3
	NVCCFLAGS  += -O3
ifeq ($(PROFILE),Yes)
	CCFLAGS += -g 
	CXXFLAGS   += -g
	NVCCFLAGS  += -g
endif
else ifeq ($(MODE),Debug)
	CFLAGS += -g -O0
	CXXFLAGS   += -g -O0
	NVCCFLAGS  += -g -G -O0
endif


C_SRC=./ext/karlin/src/karlin.c 

CPP_SRC=./ext/seg/src/seg.cpp \
	./src/align_main.cpp    \
	./src/protein_sequence.cpp \
	./src/aligner.cpp \
	./src/protein_type.cpp \
	./src/aligner_build_results_thread.cpp \
	./src/queries.cpp \
	./src/aligner_common.cpp \
	./src/query.cpp \
	./src/aligner_gpu.cpp \
	./src/reduced_alphabet_coder.cpp \
	./src/aligner_gpu_presearch_thread.cpp \
	./src/reduced_alphabet_file_reader.cpp \
	./src/aligner_presearch_thread.cpp \
	./src/reduced_alphabet_k_mer_hash_function.cpp \
	./src/alphabet_coder.cpp \
	./src/reduced_alphabet_variable_hash_function.cpp \
	./src/chain_filter.cpp \
	./src/score_matrix.cpp \
	./src/database.cpp \
	./src/score_matrix_reader.cpp \
	./src/database_build_main.cpp \
	./src/seed_searcher.cpp \
	./src/database_chunk.cpp \
	./src/seed_searcher_common.cpp \
	./src/distance_calculation_seed_list.cpp \
	./src/seed_searcher_database_parameters.cpp \
	./src/distance_calculator.cpp \
	./src/seed_searcher_gpu.cpp \
	./src/dna_sequence.cpp \
	./src/seed_searcher_gpu_query_parameters.cpp \
	./src/dna_type.cpp \
	./src/seed_searcher_query_parameters.cpp \
	./src/edit_blocks.cpp \
	./src/sequence.cpp \
	./src/extension_seed_list.cpp \
	./src/sequence_no_filter.cpp \
	./src/fasta_sequence_reader.cpp \
	./src/sequence_seg_filter.cpp \
	./src/gapped_extender.cpp \
	./src/sequence_type.cpp \
	./src/gpu_stream_controller.cpp \
	./src/statistics.cpp \
	./src/gpu_stream_runner.cpp \
	./src/translated_dna_query.cpp \
	./src/host_seeds_memory.cpp \
	./src/translator.cpp \
	./src/k_mer_sequences_index.cpp \
	./src/ungapped_extender.cpp \
	./src/main.cpp \
	./src/ungapped_extension_with_trigger_seed_list.cpp \
	./src/one_mismatch_hash_generator.cpp \
	./src/variable_hash_clustering_seuences_index.cpp \
	./src/protein_query.cpp \
	./src/variable_hash_sequences_index.cpp

CU_SRC=./src/aligner_gpu_data.cu \
	./src/distance_calculator_gpu_ref_kernel.cu \
	./src/packed_alphabet_code.cu \
	./src/device_seeds_memory.cu \
	./src/gapped_extender_gpu.cu \
	./src/ungapped_extender_gpu.cu \
	./src/distance_calculator_gpu.cu \
	./src/gapped_extender_gpu_ref_kernel.cu \
	./src/ungapped_extender_gpu_kernel.cu


OBJS =
OBJS += $(C_SRC:%.c=%.o)
OBJS += $(CPP_SRC:%.cpp=%.o)
OBJS += $(CU_SRC:%.cu=%.o)

.SUFFIXES:	.o

.PHONY: all
all:ghostz

ghostz: $(OBJS)
	$(NVCC) $(LDLIBS) $(LDFLAGS) -o $(EXECUTABLE) $(OBJS)

%.o: %.c
	$(CC) -c $(CFLAGS) $< -o $@  $(INCLUDES)

%.o: %.cpp
	$(CXX) -c $(CXXFLAGS) $< -o $@  $(INCLUDES)

%.o: %.cu
	$(NVCC) -c $(NVCCFLAGS) $< -o $@  $(INCLUDES)

.PHONY: clean
clean:
	rm -f $(OBJS) ghostz ghostz-gpu
