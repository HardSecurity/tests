#! /bin/bash

export LD_LIBRARY_PATH="$PWD"

cmd() {
    echo "$@"
    "$@"
}

check() {
    cmd "$CC" -O0 -g "$@" -o bin
    ./bin >stdout stdout || { echo -e "  \e[31mFAIL\e[m"; return; }
    grep -q "Hello ./bin" stdout || { echo -e "  \e[31mFAIL\e[m"; return; }
    rm -f bin stdout
}

# checks the availability of unsafe variables in the main thread
check basic.c
check -fPIC basic.c
check -fsafe-stack basic.c
check -fsafe-stack -fPIC basic.c
check -lpthread basic.c
check -lpthread -fPIC basic.c
check -lpthread -fsafe-stack basic.c
check -lpthread -fsafe-stack -fPIC basic.c

# checks the availability of unsafe variables in a thread
check -lpthread pthread.c
check -lpthread -fPIC pthread.c
check -lpthread -fsafe-stack pthread.c
check -lpthread -fsafe-stack -fPIC pthread.c

# checks the availability of unsafe variables in a thread,
# using user provided stack
check -lpthread pthread-user-stack.c
check -lpthread -fPIC pthread-user-stack.c
check -lpthread -fsafe-stack pthread-user-stack.c
check -lpthread -fsafe-stack -fPIC pthread-user-stack.c

# prepare dynamic libraries
cmd "$CC" -O0 -g -shared -fPIC libhello.c -o libhello.so
cmd "$CC" -O0 -g -shared -fPIC -fsafe-stack libhello.c -o libhello-safestack.so
cmd "$CC" -O0 -g -shared -fPIC libhello-pthread.c -o libhello-pthread.so -lpthread
cmd "$CC" -O0 -g -shared -fPIC -fsafe-stack libhello-pthread.c -o libhello-pthread-safestack.so -lpthread

# check linking to dynamic libraries
check link.c -L. -lhello
check link.c -L. -lhello-pthread
check link.c -L. -lhello-safestack
check link.c -L. -lhello-pthread-safestack
check -fPIC link.c -L. -lhello
check -fPIC link.c -L. -lhello-pthread
check -fPIC link.c -L. -lhello-safestack
check -fPIC link.c -L. -lhello-pthread-safestack
check -fsafe-stack link.c -L. -lhello
check -fsafe-stack link.c -L. -lhello-pthread
check -fsafe-stack link.c -L. -lhello-safestack
check -fsafe-stack link.c -L. -lhello-pthread-safestack
check -fsafe-stack -fPIC link.c -L. -lhello
check -fsafe-stack -fPIC link.c -L. -lhello-pthread
check -fsafe-stack -fPIC link.c -L. -lhello-safestack
check -fsafe-stack -fPIC link.c -L. -lhello-pthread-safestack

# check dlopen
check -ldl dlopen.c -DSHARED_LIBRARY=\"libhello.so\"
check -ldl dlopen.c -DSHARED_LIBRARY=\"libhello-pthread.so\"
check -ldl dlopen.c -DSHARED_LIBRARY=\"libhello-safestack.so\"
check -ldl dlopen.c -DSHARED_LIBRARY=\"libhello-pthread-safestack.so\"
check -ldl -fPIC dlopen.c -DSHARED_LIBRARY=\"libhello.so\"
check -ldl -fPIC dlopen.c -DSHARED_LIBRARY=\"libhello-pthread.so\"
check -ldl -fPIC dlopen.c -DSHARED_LIBRARY=\"libhello-safestack.so\"
check -ldl -fPIC dlopen.c -DSHARED_LIBRARY=\"libhello-pthread-safestack.so\"
check -ldl -fsafe-stack dlopen.c -DSHARED_LIBRARY=\"libhello.so\"
check -ldl -fsafe-stack dlopen.c -DSHARED_LIBRARY=\"libhello-pthread.so\"
check -ldl -fsafe-stack dlopen.c -DSHARED_LIBRARY=\"libhello-safestack.so\"
check -ldl -fsafe-stack dlopen.c -DSHARED_LIBRARY=\"libhello-pthread-safestack.so\"
check -ldl -fsafe-stack -fPIC dlopen.c -DSHARED_LIBRARY=\"libhello.so\"
check -ldl -fsafe-stack -fPIC dlopen.c -DSHARED_LIBRARY=\"libhello-pthread.so\"
check -ldl -fsafe-stack -fPIC dlopen.c -DSHARED_LIBRARY=\"libhello-safestack.so\"
check -ldl -fsafe-stack -fPIC dlopen.c -DSHARED_LIBRARY=\"libhello-pthread-safestack.so\"

# check 10000 unsafe stack allocation for memory leak

# cleanup
# rm -f bin stdout *.so
