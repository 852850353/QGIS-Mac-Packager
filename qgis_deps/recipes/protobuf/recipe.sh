#!/bin/bash

DESC_protobuf="Protocol buffers (Google's data interchange format)"

# version of your package
VERSION_protobuf=3.11.4

LINK_protobuf_version=22

# dependencies of this recipe
DEPS_protobuf=(zlib)

# url of the package
URL_protobuf=https://github.com/protocolbuffers/protobuf/releases/download/v${VERSION_protobuf}/protobuf-cpp-${VERSION_protobuf}.tar.gz

# md5 of the package
MD5_protobuf=44fa1fde51cc21c79d0e64caef2d2933

# default build path
BUILD_protobuf=$BUILD_PATH/protobuf/$(get_directory $URL_protobuf)

# default recipe path
RECIPE_protobuf=$RECIPES_PATH/protobuf

patch_protobuf_linker_links () {
  install_name_tool -id "@rpath/libprotobuf.dylib" ${STAGE_PATH}/lib/libprotobuf.dylib
  install_name_tool -id "@rpath/libprotobuf-lite.dylib" ${STAGE_PATH}/lib/libprotobuf-lite.dylib
  install_name_tool -id "@rpath/libprotoc.dylib" ${STAGE_PATH}/lib/libprotoc.dylib

  if [ ! -f "${STAGE_PATH}/lib/libprotobuf.${LINK_protobuf_version}.dylib" ]; then
    error "file ${STAGE_PATH}/lib/libprotobuf.${LINK_protobuf_version}.dylib does not exist... maybe you updated the protobuf version?"
  fi

  install_name_tool -change "${STAGE_PATH}/lib/libprotobuf.${LINK_protobuf_version}.dylib" "@rpath/libprotobuf.${LINK_protobuf_version}.dylib" ${STAGE_PATH}/lib/libprotoc.dylib

  targets=(
    bin/protoc
  )

  # Change linked libs
  for i in ${targets[*]}
  do
      install_name_tool -change "${STAGE_PATH}/lib/libprotobuf.${LINK_protobuf_version}.dylib" "@rpath/libprotobuf.${LINK_protobuf_version}.dylib" ${STAGE_PATH}/$i
      install_name_tool -change "${STAGE_PATH}/lib/libprotoc.${LINK_protobuf_version}.dylib" "@rpath/libprotoc.${LINK_protobuf_version}.dylib" ${STAGE_PATH}/$i
      install_name_tool -add_rpath @executable_path/../lib ${STAGE_PATH}/$i
  done

}

# function called for preparing source code if needed
# (you can apply patch etc here.)
function prebuild_protobuf() {
  cd $BUILD_protobuf
  patch_protobuf_linker_links
  # check marker
  if [ -f .patched ]; then
    return
  fi

  touch .patched
}

function shouldbuild_protobuf() {
  # If lib is newer than the sourcecode skip build
  if [ ${STAGE_PATH}/lib/libprotobuf.dylib -nt $BUILD_protobuf/.patched ]; then
    DO_BUILD=0
  fi
}

# function called to build the source code
function build_protobuf() {
  try rsync -a $BUILD_protobuf/ $BUILD_PATH/protobuf/build-$ARCH/
  try cd $BUILD_PATH/protobuf/build-$ARCH
  push_env

  export CXXFLAGS="$CXXFLAGS -DNDEBUG"

  try ./autogen.sh
  patch_configure_file configure
  try ${CONFIGURE} \
    --disable-debug \
    --disable-dependency-tracking \
    --with-zlib

  check_file_configuration config.status
  try $MAKESMP
  try $MAKESMP install

  patch_protobuf_linker_links

  pop_env
}

# function called after all the compile have been done
function postbuild_protobuf() {
  verify_lib "libprotobuf.dylib"
  verify_lib "libprotobuf-lite.dylib"
  verify_lib "libprotoc.dylib"

  verify_bin "protoc"
}
