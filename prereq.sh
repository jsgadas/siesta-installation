#!/bin/bash 
set -e

# install required ubuntu packages using apt
sudo apt update
sudo apt install -y python curl unzip
sudo apt install -y hwloc sysstat
sudo apt install -y build-essential g++ gfortran libreadline-dev m4 xsltproc
sudo apt install -y mpich libmpich-dev

box_out "Ubuntu package installation OK"

# create installation directories
if [[ ! -d $BASE_DIR ]]; then
  sudo mkdir -p $BASE_DIR
fi
sudo mkdir $SIESTA_DIR $OPENBLAS_DIR $SCALAPACK_DIR
sudo chmod -R 777 $SIESTA_DIR $OPENBLAS_DIR $SCALAPACK_DIR

box_out "Created target directories..."

# download and extract requried source files

# download and extract OpenBLAS source files
cd $OPENBLAS_DIR
curl -kLo OpenBLAS.tar.gz --progress-bar https://ufpr.dl.sourceforge.net/project/openblas/v0.3.3/OpenBLAS%200.3.3%20version.tar.gz
tar xzf OpenBLAS.tar.gz && rm OpenBLAS.tar.gz

# download and extract Siesta source
cd $SIESTA_DIR
curl -kLo "siesta-$SIESTA_FULL_VERSION.tar.gz" --progress-bar "https://launchpad.net/siesta/$SIESTA_PART_VERSION/$SIESTA_FULL_VERSION/+download/siesta-$SIESTA_FULL_VERSION.tar.gz"
tar xzf "siesta-$SIESTA_FULL_VERSION.tar.gz" && rm "siesta-$SIESTA_FULL_VERSION.tar.gz"

box_out "Downloaded dependent packages..."

# read versions of flook, zlib, hdf5, netcdf-c and netcdf-fortran
FLOOK_VERSION=$(cat "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Docs/install_flook.bash" | grep f_v= | cut -d'=' -f 2)
ZLIB_VERSION=$(cat "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Docs/install_netcdf4.bash" | grep z_v= | cut -d'=' -f 2)
HDF_FULL_VERSION=$(cat "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Docs/install_netcdf4.bash" | grep h_v= | cut -d'=' -f 2)
HDF_PART_VERSION=$(echo $HDF_FULL_VERSION | sed -E 's/([0-9]+\.[0-9]+)\.[0-9]+/\1/')
NC_VERSION=$(cat "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Docs/install_netcdf4.bash" | grep nc_v= | cut -d'=' -f 2)
NF_VERSION=$(cat "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Docs/install_netcdf4.bash" | grep nf_v= | cut -d'=' -f 2)

box_out "Going to install the following libraries:" "+FLOOK v$FLOOK_VERSION" "+ZLIB v$ZLIB_VERSION" "+HDF5 v$HDF_FULL_VERSION" "+NETCDF_C v$NC_VERSION" "+NETCDF_FORTRAN v$NF_VERSION"

# download Siesta dependencies
cd "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Docs"
curl -kLo "flook-$FLOOK_VERSION.tar.gz" --progress-bar "https://github.com/ElectronicStructureLibrary/flook/releases/download/v$FLOOK_VERSION/flook-$FLOOK_VERSION.tar.gz"
curl -kLo "zlib-$ZLIB_VERSION.tar.gz" --progress-bar "https://zlib.net/zlib-$ZLIB_VERSION.tar.gz"
curl -kLo "hdf5-$HDF_FULL_VERSION.tar.bz2" --progress-bar "https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-$HDF_PART_VERSION/hdf5-$HDF_FULL_VERSION/src/hdf5-$HDF_FULL_VERSION.tar.bz2"
curl -kLo "netcdf-c-$NC_VERSION.tar.gz" --progress-bar "https://github.com/Unidata/netcdf-c/archive/v$NC_VERSION.tar.gz"
curl -kLo "netcdf-fortran-$NF_VERSION.tar.gz" --progress-bar "https://github.com/Unidata/netcdf-fortran/archive/v$NF_VERSION.tar.gz"

box_out "Downloaded package files..."

# install OpenBLAS
cd $OPENBLAS_DIR
cd "$(find . -type d -name xianyi-OpenBLAS*)"
make DYNAMIC_ARCH=0 CC=gcc FC=gfortran HOSTCC=gcc BINARY=64 INTERFACE=64 NO_AFFINITY=1 NO_WARMUP=1 USE_OPENMP=0 USE_THREAD=0 LIBNAMESUFFIX=nonthreaded > blas1.log 2>&1
make PREFIX=$OPENBLAS_DIR LIBNAMESUFFIX=nonthreaded install > blas2.log 2>&1
cd $OPENBLAS_DIR && rm -rf "$(find $OPENBLAS_DIR -maxdepth 1 -type d -name xianyi-OpenBLAS*)"

box_out "Installed OpenBLAS..."

# install ScaLAPACK
cd $SCALAPACK_DIR
cp $CURRENT_DIR/scalapack_installer.zip ./
unzip scalapack_installer.zip
cd scalapack_installer
./setup.py --prefix $SCALAPACK_DIR --blaslib=$OPENBLAS_DIR/lib/libopenblas_nonthreaded.a --lapacklib=$OPENBLAS_DIR/lib/libopenblas_nonthreaded.a --mpibindir=/usr/bin --mpiincdir=/usr/lib/mpich/include > scalapack.log 2>&1

box_out "Installed ScaLapack..."

# install Siesta dependencies
cd "$SIESTA_DIR/siesta-$SIESTA_FULL_VERSION/Docs"
(./install_flook.bash 2>&1) | tee install_flook.log
(./install_netcdf4.bash 2>&1) | tee install_netcdf4.log

box_out "Prerequisite Installation OK" "" "Installed the following libraries:" "+OpenBLAS v0.3.3" "+ScaLAPACK v$SCALAPACK_VERSION" "+FLOOK v$FLOOK_VERSION" "+ZLIB v$ZLIB_VERSION" "+HDF5 v$HDF_FULL_VERSION" "+NETCDF_C v$NC_VERSION" "+NETCDF_FORTRAN v$NF_VERSION"
read -p "Press Enter to continue..."
