#!/bin/bash

function check_postgres() {
  env_var_exists VERSION_postgres
  env_var_exists QGIS_VERSION
  env_var_exists VERSION_grass_major
}

function bundle_postgres() {
  try cp -av $DEPS_LIB_DIR/libpq.*dylib $BUNDLE_LIB_DIR/
}

function postbundle_postgres() {
 install_name_id @rpath/$LINK_libpq $BUNDLE_CONTENTS_DIR/MacOS/lib/$LINK_libpq

 install_name_change $DEPS_LIB_DIR/$LINK_libpq @rpath/$LINK_libpq $BUNDLE_CONTENTS_DIR/MacOS/QGIS
 install_name_change $DEPS_LIB_DIR/$LINK_libpq @rpath/$LINK_libpq $BUNDLE_CONTENTS_DIR/PlugIns/qgis/libpostgresrasterprovider.so
 install_name_change $DEPS_LIB_DIR/$LINK_libpq @rpath/$LINK_libpq $BUNDLE_CONTENTS_DIR/PlugIns/qgis/libpostgresprovider.so
 install_name_change $DEPS_LIB_DIR/$LINK_libpq @rpath/$LINK_libpq $BUNDLE_CONTENTS_DIR/PlugIns/qgis/libgrassplugin${VERSION_grass_major}.so
 install_name_change $DEPS_LIB_DIR/$LINK_libpq @rpath/$LINK_libpq $BUNDLE_CONTENTS_DIR/MacOS/lib/libqgis_app.${QGIS_VERSION}.0.dylib
 install_name_change $DEPS_LIB_DIR/$LINK_libpq @rpath/$LINK_libpq $BUNDLE_CONTENTS_DIR/MacOS/lib/saga/libdb_pgsql.dylib
 install_name_change $DEPS_LIB_DIR/$LINK_libpq @rpath/$LINK_libpq $BUNDLE_CONTENTS_DIR/MacOS/lib/$LINK_gdal
 install_name_change $DEPS_LIB_DIR/$LINK_libpq @rpath/$LINK_libpq $BUNDLE_CONTENTS_DIR/Resources/python/site-packages/psycopg2/_psycopg.cpython-37m-darwin.so
}
