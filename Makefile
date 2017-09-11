NEED_LIBPROTOC=1
include config.mk

# Notes on the flags:
# 1. Added -fno-omit-frame-pointer: perf/tcmalloc-profiler use frame pointers by default
# 2. Added -D__const__= : Avoid over-optimizations of TLS variables by GCC>=4.8
# 3. Removed -Werror: Not block compilation for non-vital warnings, especially when the
#    code is tested on newer systems. If the code is used in production, add -Werror back
CPPFLAGS=-DBTHREAD_USE_FAST_PTHREAD_MUTEX -D__const__= -D_GNU_SOURCE -DUSE_SYMBOLIZE -DNO_TCMALLOC -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -D__STDC_CONSTANT_MACROS -DBRPC_REVISION=\"$(shell git rev-parse --short HEAD)\"
CXXFLAGS=$(CPPFLAGS) -g -O2 -pipe -Wall -W -fPIC -fstrict-aliasing -Wno-invalid-offsetof -Wno-unused-parameter -fno-omit-frame-pointer -std=c++0x
CFLAGS=$(CPPFLAGS) -g -O2 -pipe -Wall -W -fPIC -fstrict-aliasing -Wno-unused-parameter -fno-omit-frame-pointer
HDRPATHS=-I./src $(addprefix -I, $(HDRS))
LIBPATHS = $(addprefix -L, $(LIBS))
SRCEXTS = .c .cc .cpp .proto
HDREXTS = .h .hpp

#required by butil/crc32.cc to boost performance for 10x
ifeq ($(shell test $(GCC_VERSION) -ge 40400; echo $$?),0)
	CXXFLAGS+=-msse4 -msse4.2
endif
#not solved yet
ifeq ($(shell test $(GCC_VERSION) -ge 70000; echo $$?),0)
	CXXFLAGS+=-Wno-aligned-new
endif

BUTIL_SOURCES = \
    src/butil/third_party/dmg_fp/g_fmt.cc \
    src/butil/third_party/dmg_fp/dtoa_wrapper.cc \
    src/butil/third_party/dynamic_annotations/dynamic_annotations.c \
    src/butil/third_party/icu/icu_utf.cc \
    src/butil/third_party/superfasthash/superfasthash.c \
    src/butil/third_party/modp_b64/modp_b64.cc \
    src/butil/third_party/nspr/prtime.cc \
    src/butil/third_party/symbolize/demangle.cc \
    src/butil/third_party/symbolize/symbolize.cc \
    src/butil/third_party/xdg_mime/xdgmime.c \
    src/butil/third_party/xdg_mime/xdgmimealias.c \
    src/butil/third_party/xdg_mime/xdgmimecache.c \
    src/butil/third_party/xdg_mime/xdgmimeglob.c \
    src/butil/third_party/xdg_mime/xdgmimeicon.c \
    src/butil/third_party/xdg_mime/xdgmimeint.c \
    src/butil/third_party/xdg_mime/xdgmimemagic.c \
    src/butil/third_party/xdg_mime/xdgmimeparent.c \
    src/butil/third_party/xdg_user_dirs/xdg_user_dir_lookup.cc \
    src/butil/third_party/snappy/snappy-sinksource.cc \
    src/butil/third_party/snappy/snappy-stubs-internal.cc \
    src/butil/third_party/snappy/snappy.cc \
    src/butil/third_party/murmurhash3/murmurhash3.cpp \
    src/butil/allocator/type_profiler_control.cc \
    src/butil/arena.cpp \
    src/butil/at_exit.cc \
    src/butil/atomicops_internals_x86_gcc.cc \
    src/butil/barrier_closure.cc \
    src/butil/base_paths.cc \
    src/butil/base_paths_posix.cc \
    src/butil/base64.cc \
    src/butil/base_switches.cc \
    src/butil/big_endian.cc \
    src/butil/bind_helpers.cc \
    src/butil/callback_helpers.cc \
    src/butil/callback_internal.cc \
    src/butil/command_line.cc \
    src/butil/cpu.cc \
    src/butil/debug/alias.cc \
    src/butil/debug/asan_invalid_access.cc \
    src/butil/debug/crash_logging.cc \
    src/butil/debug/debugger.cc \
    src/butil/debug/debugger_posix.cc \
    src/butil/debug/dump_without_crashing.cc \
    src/butil/debug/proc_maps_linux.cc \
    src/butil/debug/stack_trace.cc \
    src/butil/debug/stack_trace_posix.cc \
    src/butil/environment.cc \
    src/butil/files/file.cc \
    src/butil/files/file_posix.cc \
    src/butil/files/file_enumerator.cc \
    src/butil/files/file_enumerator_posix.cc \
    src/butil/files/file_path.cc \
    src/butil/files/file_path_constants.cc \
    src/butil/files/memory_mapped_file.cc \
    src/butil/files/memory_mapped_file_posix.cc \
    src/butil/files/scoped_file.cc \
    src/butil/files/scoped_temp_dir.cc \
    src/butil/file_util.cc \
    src/butil/file_util_linux.cc \
    src/butil/file_util_posix.cc \
    src/butil/guid.cc \
    src/butil/guid_posix.cc \
    src/butil/hash.cc \
    src/butil/lazy_instance.cc \
    src/butil/location.cc \
    src/butil/md5.cc \
    src/butil/memory/aligned_memory.cc \
    src/butil/memory/ref_counted.cc \
    src/butil/memory/ref_counted_memory.cc \
    src/butil/memory/shared_memory_posix.cc \
    src/butil/memory/singleton.cc \
    src/butil/memory/weak_ptr.cc \
    src/butil/nix/mime_util_xdg.cc \
    src/butil/nix/xdg_util.cc \
    src/butil/path_service.cc \
    src/butil/posix/file_descriptor_shuffle.cc \
    src/butil/posix/global_descriptors.cc \
    src/butil/process/internal_linux.cc \
    src/butil/process/kill.cc \
    src/butil/process/kill_posix.cc \
    src/butil/process/launch.cc \
    src/butil/process/launch_posix.cc \
    src/butil/process/process_handle_linux.cc \
    src/butil/process/process_handle_posix.cc \
    src/butil/process/process_info_linux.cc \
    src/butil/process/process_iterator.cc \
    src/butil/process/process_iterator_linux.cc \
    src/butil/process/process_linux.cc \
    src/butil/process/process_metrics.cc \
    src/butil/process/process_metrics_linux.cc \
    src/butil/process/process_metrics_posix.cc \
    src/butil/process/process_posix.cc \
    src/butil/rand_util.cc \
    src/butil/rand_util_posix.cc \
    src/butil/fast_rand.cpp \
    src/butil/safe_strerror_posix.cc \
    src/butil/sha1_portable.cc \
    src/butil/strings/latin1_string_conversions.cc \
    src/butil/strings/nullable_string16.cc \
    src/butil/strings/safe_sprintf.cc \
    src/butil/strings/string16.cc \
    src/butil/strings/string_number_conversions.cc \
    src/butil/strings/string_split.cc \
    src/butil/strings/string_piece.cc \
    src/butil/strings/string_util.cc \
    src/butil/strings/string_util_constants.cc \
    src/butil/strings/stringprintf.cc \
    src/butil/strings/sys_string_conversions_posix.cc \
    src/butil/strings/utf_offset_string_conversions.cc \
    src/butil/strings/utf_string_conversion_utils.cc \
    src/butil/strings/utf_string_conversions.cc \
    src/butil/synchronization/cancellation_flag.cc \
    src/butil/synchronization/condition_variable_posix.cc \
    src/butil/synchronization/waitable_event_posix.cc \
    src/butil/sys_info.cc \
    src/butil/sys_info_linux.cc \
    src/butil/sys_info_posix.cc \
    src/butil/threading/non_thread_safe_impl.cc \
    src/butil/threading/platform_thread_linux.cc \
    src/butil/threading/platform_thread_posix.cc \
    src/butil/threading/simple_thread.cc \
    src/butil/threading/thread_checker_impl.cc \
    src/butil/threading/thread_collision_warner.cc \
    src/butil/threading/thread_id_name_manager.cc \
    src/butil/threading/thread_local_posix.cc \
    src/butil/threading/thread_local_storage.cc \
    src/butil/threading/thread_local_storage_posix.cc \
    src/butil/threading/thread_restrictions.cc \
    src/butil/threading/watchdog.cc \
    src/butil/time/clock.cc \
    src/butil/time/default_clock.cc \
    src/butil/time/default_tick_clock.cc \
    src/butil/time/tick_clock.cc \
    src/butil/time/time.cc \
    src/butil/time/time_posix.cc \
    src/butil/version.cc \
    src/butil/logging.cc \
    src/butil/class_name.cpp \
    src/butil/errno.cpp \
    src/butil/find_cstr.cpp \
    src/butil/status.cpp \
    src/butil/string_printf.cpp \
    src/butil/thread_local.cpp \
    src/butil/unix_socket.cpp \
    src/butil/endpoint.cpp \
    src/butil/fd_utility.cpp \
    src/butil/files/temp_file.cpp \
    src/butil/files/file_watcher.cpp \
    src/butil/time.cpp \
    src/butil/zero_copy_stream_as_streambuf.cpp \
    src/butil/crc32c.cc \
    src/butil/containers/case_ignored_flat_map.cpp \
    src/butil/iobuf.cpp

BUTIL_OBJS = $(addsuffix .o, $(basename $(BUTIL_SOURCES)))

BVAR_DIRS = src/bvar src/bvar/detail
BVAR_SOURCES = $(foreach d,$(BVAR_DIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
BVAR_OBJS = $(addsuffix .o, $(basename $(BVAR_SOURCES))) 

BTHREAD_DIRS = src/bthread
BTHREAD_SOURCES = $(foreach d,$(BTHREAD_DIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
BTHREAD_OBJS = $(addsuffix .o, $(basename $(BTHREAD_SOURCES))) 

JSON2PB_DIRS = src/json2pb
JSON2PB_SOURCES = $(foreach d,$(JSON2PB_DIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
JSON2PB_OBJS = $(addsuffix .o, $(basename $(JSON2PB_SOURCES))) 

BRPC_DIRS = src/brpc src/brpc/details src/brpc/builtin src/brpc/policy
BRPC_SOURCES = $(foreach d,$(BRPC_DIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
BRPC_PROTOS = $(filter %.proto,$(BRPC_SOURCES))
BRPC_CFAMILIES = $(filter-out %.proto,$(BRPC_SOURCES))
BRPC_OBJS = $(BRPC_PROTOS:.proto=.pb.o) $(addsuffix .o, $(basename $(BRPC_CFAMILIES)))

MCPACK2PB_SOURCES = \
	src/mcpack2pb/field_type.cpp \
	src/mcpack2pb/mcpack2pb.cpp \
	src/mcpack2pb/parser.cpp \
	src/mcpack2pb/serializer.cpp
MCPACK2PB_OBJS = src/idl_options.pb.o $(addsuffix .o, $(basename $(MCPACK2PB_SOURCES)))

OBJS=$(BUTIL_OBJS) $(BVAR_OBJS) $(BTHREAD_OBJS) $(JSON2PB_OBJS) $(MCPACK2PB_OBJS) $(BRPC_OBJS)
DEBUG_OBJS = $(OBJS:.o=.dbg.o)

.PHONY:all
all:  protoc-gen-mcpack libbrpc.a output/include output/lib output/bin

.PHONY:debug
debug: libbrpc.dbg.a

.PHONY:clean
clean:clean_debug
	@echo "Cleaning"
	@rm -rf mcpack2pb/generator.o protoc-gen-mcpack libbrpc.a $(OBJS) output/include output/lib output/bin

.PHONY:clean_debug
clean_debug:
	@rm -rf libbrpc.dbg.a $(DEBUG_OBJS)

protoc-gen-mcpack: src/idl_options.pb.cc src/mcpack2pb/generator.o libbrpc.a
	@echo "Linking $@"
	@$(CXX) -o $@ $(HDRPATHS) $(LIBPATHS) -Xlinker "-(" $^ -Wl,-Bstatic $(STATIC_LINKINGS) -Wl,-Bdynamic -Xlinker "-)" $(DYNAMIC_LINKINGS)

# force generation of pb headers before compiling to avoid fail-to-import issues in compiling pb.cc
libbrpc.a:$(BRPC_PROTOS:.proto=.pb.h) $(OBJS)
	@echo "Packing $@"
	@ar crs $@ $(OBJS)

libbrpc.dbg.a:$(BRPC_PROTOS:.proto=.pb.h) $(DEBUG_OBJS)
	@echo "Packing $@"
	@ar crs $@ $(DEBUG_OBJS)

.PHONY:output/include
output/include:
	@echo "Copying to $@"
	@for dir in `find src -type f -name "*.h" -exec dirname {} \\; | sed -e 's/^src\///g' -e '/^src$$/d' | sort | uniq`; do mkdir -p $@/$$dir && cp src/$$dir/*.h $@/$$dir/; done
	@for dir in `find src -type f -name "*.hpp" -exec dirname {} \\; | sed -e 's/^src\///g' -e '/^src$$/d' | sort | uniq`; do mkdir -p $@/$$dir && cp src/$$dir/*.hpp $@/$$dir/; done
	@cp src/idl_options.proto src/idl_options.pb.h $@

.PHONY:output/lib
output/lib:libbrpc.a
	@echo "Copying to $@"
	@mkdir -p $@
	@cp $^ $@

.PHONY:output/bin
output/bin:protoc-gen-mcpack
	@echo "Copying to $@"
	@mkdir -p $@
	@cp $^ $@

%.pb.cc %.pb.h:%.proto
	@echo "Generating $@"
	@$(PROTOC) --cpp_out=./src --proto_path=./src --proto_path=$(PROTOBUF_HDR) $<

%.o:%.cpp
	@echo "Compiling $@"
	@$(CXX) -c $(HDRPATHS) $(CXXFLAGS) -DNDEBUG $< -o $@

%.dbg.o:%.cpp
	@echo "Compiling $@"
	@$(CXX) -c $(HDRPATHS) $(CXXFLAGS) $< -o $@

%.o:%.cc
	@echo "Compiling $@"
	@$(CXX) -c $(HDRPATHS) $(CXXFLAGS) -DNDEBUG $< -o $@

%.dbg.o:%.cc
	@echo "Compiling $@"
	@$(CXX) -c $(HDRPATHS) $(CXXFLAGS) $< -o $@

%.o:%.c
	@echo "Compiling $@"
	@$(CC) -c $(HDRPATHS) $(CFLAGS) -DNDEBUG $< -o $@

%.dbg.o:%.c
	@echo "Compiling $@"
	@$(CC) -c $(HDRPATHS) $(CFLAGS) $< -o $@