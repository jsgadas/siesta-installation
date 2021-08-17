#!/bin/bash
set -e

# generate sources
cd "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Obj"
sh "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Src/obj_setup.sh" > siesta1.log 2>&1

# create arch.make file
. "$CURRENT_DIR/arch.sh"

# copy Obj directory for Transiesta
cd "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION"
cp -r Obj Obj_ts

# make Siesta
box_out "Installing Siesta..."
cd "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Obj"
make OBJDIR=Obj > siesta2.log 2>&1

box_out "Siesta Installation OK"

# make Transiesta
box_out "Installing Transiesta..."
cd "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Obj_ts"
make transiesta OBJDIR=Obj_ts > siesta3.log 2>&1

box_out "Transiesta Installation OK"

# make TBtrans
box_out "Installing TBtrans..."
cd "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Util/TS/TBtrans"
make OBJDIR=Obj_ts > siesta4.log 2>&1

box_out "TBtrans Installation OK"

# create symlinks
#sudo ln -s "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Obj/siesta" /usr/local/bin/siesta
#sudo ln -s "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Obj_ts/transiesta" /usr/local/bin/transiesta
#sudo ln -s "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Util/TS/TBtrans/tbtrans" /usr/local/bin/tbtrans

box_out "Installation Completed!"

exit


