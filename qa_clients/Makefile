QA_CLIENTS ?= qa_consumer qa_producer qa_performance

all: $(QA_CLIENTS)

include ../mklove/Makefile.base

CFLAGS += -I../src
CXXFLAGS += -I../src-cpp

# librdkafka must be compiled with -gstrict-dwarf, but rdkafka_example must not,
# due to some clang bug on OSX 10.9
CPPFLAGS := $(subst strict-dwarf,,$(CPPFLAGS))


qa_performance: ../src/librdkafka.a qa_performance.c
	$(CC) $(CPPFLAGS) $(CFLAGS) qa_performance.c -o $@ $(LDFLAGS) \
		../src/librdkafka.a $(LIBS)
	@echo "# $@ is ready"
	@echo "#"
	@echo "# Run producer"
	@echo "./$@ -P -t <topic> -p <partition> -s <msgsize>"
	@echo ""
	@echo "# or consumer"
	@echo "./$@ -C -t <topic> -p <partition>"
	@echo ""
	@echo "#"
	@echo "# More usage options:"
	@echo "./$@ -h"

qa_producer: ../src-cpp/librdkafka++.a ../src/librdkafka.a qa_producer.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) qa_producer.cpp -o $@ $(LDFLAGS) \
		../src-cpp/librdkafka++.a ../src/librdkafka.a $(LIBS) -lstdc++

qa_consumer: ../src-cpp/librdkafka++.a ../src/librdkafka.a qa_consumer.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) qa_consumer.cpp -o $@ $(LDFLAGS) \
		../src-cpp/librdkafka++.a ../src/librdkafka.a $(LIBS) -lstdc++


clean:
	rm -f $(QA_CLIENTS)

