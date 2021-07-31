docker run \
    -v $(pwd):/tmp/build \
    shukriadams/platformio:0.0.1 sh -c 'cd /tmp/build && ./build.sh'