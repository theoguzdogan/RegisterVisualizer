cd `dirname $0`
SCRIPTDIR=`pwd`
cd -

mkdir $SCRIPTDIR/../build

/home/renda/Qt/Tools/CMake/bin/cmake \
-DCMAKE_PREFIX_PATH:STRING=/home/renda/Qt/5.15.2/gcc_64/lib/cmake/ \
-DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE \
-DCMAKE_BUILD_TYPE:STRING=Release \
-DCMAKE_CXX_COMPILER:FILEPATH=/usr/bin/g++ \
-S$SCRIPTDIR/../ \
-B$SCRIPTDIR/../build/ \
-G "Unix Makefiles"

cmake \
--build $SCRIPTDIR/../build/ \
--config Release \
--target all \
-j$((`nproc`+2)) --