
################## INSTALL GCC 10.2 ################################################

cd $DOWNLOAD
wget https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
tar -xzvf gcc-${GCC_VERSION}.tar.gz
cd gcc-${GCC_VERSION}
./contrib/download_prerequisites
mkdir obj.gcc-${GCC_VERSION}
cd obj.gcc-${GCC_VERSION}
../configure --disable-multilib --enable-languages=c,c++,fortran --prefix=${WRF_INSTALL}/gcc-${GCC_VERSION}
make -j $(nproc) && make install

################## INSTALL OpenMPI ################################################

cd $DOWNLOAD
wget -N https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.0.tar.gz
tar -xzvf openmpi-4.1.0.tar.gz
cd openmpi-4.1.0
mkdir build
cd build
../configure --prefix=${WRF_INSTALL}/openmpi-${OPENMPI_VERSION} --enable-mpirun-prefix-by-default
make -j$(nproc) && make install

################## INSTALL ZLIB ################################################

cd $DOWNLOAD
wget -N http://www.zlib.net/zlib-1.2.11.tar.gz
tar -xzvf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure --prefix=${WRF_INSTALL}/zlib
make check && make install

################## INSTALL HDF5 ################################################

cd $DOWNLOAD
curl -o hdf5-1.12.0.tar.gz -J -L https://www.hdfgroup.org/package/hdf5-1-12-0-tar-gz/?wpdmdl=14582
tar -xzvf hdf5-1.12.0.tar.gz
cd hdf5-1.12.0
./configure --prefix=${WRF_INSTALL}/hdf5 --with-zlib=${WRF_INSTALL}/zlib --enable-parallel --enable-shared --enable-hl --enable-fortran
make -j$(nproc) && make install

################## INSTALL Parallel-NETCDF ################################################

cd $DOWNLOAD
wget -N https://parallel-netcdf.github.io/Release/pnetcdf-1.12.2.tar.gz
tar -xzvf pnetcdf-1.12.2.tar.gz
cd pnetcdf-1.12.2
./configure --prefix=${WRF_INSTALL}/pnetcdf --enable-fortran --enable-large-file-test --enable-shared
make -j$(nproc) && make install

################## INSTALL NETCDF ################################################

cd $DOWNLOAD
wget -N https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-c-4.7.4.tar.gz
tar -xzvf netcdf-c-4.7.4.tar.gz
cd netcdf-c-4.7.4
./configure --prefix=$NCDIR CPPFLAGS="-I$HDF5/include -I$PNET/include" CFLAGS="-DHAVE_STRDUP -O3 -march=armv8.2-a+crypto+fp16+rcpc+dotprod" LDFLAGS="-L$HDF5/lib -L$PNET/lib" --enable-pnetcdf --enable-large-file-tests --enable-largefile  --enable-parallel-tests --enable-shared --enable-netcdf-4  --with-pic --disable-doxygen --disable-dap
make -j$(nproc) && make install

cd $DOWNLOAD
wget -N https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-fortran-4.5.3.tar.gz
tar -xzvf netcdf-fortran-4.5.3.tar.gz
cd netcdf-fortran-4.5.3
./configure --prefix=$NCDIR --disable-static --enable-shared --with-pic --enable-parallel-tests --enable-large-file-tests --enable-largefile
make -j$(nproc) && make install

################## INSTALL WRF ################################################

cd ${WRF_INSTALL}
curl -o WRF-v4.2.2.zip -J -L https://github.com/wrf-model/WRF/archive/v4.2.2.zip
unzip WRF-v4.2.2.zip
cd WRF-4.2.2

./configure <<@EOF
8
1
@EOF
# 8. (dm+sm) GCC (gfortran/gcc): Aarch64
# Select Option 1 -Compile for nesting? (1=basic, 2=preset moves, 3=vortex following) [default 1]:

./compile -j $(nproc) em_real 2>&1 | tee compile_wrf.out

################## INSTALL Jasper ################################################

cd $DOWNLOAD
wget https://www2.mmm.ucar.edu/wrf/OnLineTutorial/compile_tutorial/tar_files/jasper-1.900.1.tar.gz
tar -xzvf jasper-1.900.1.tar.gz

cd $DOWNLOAD/jasper-1.900.1
wget -N -O acaux/config.guess "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD"
./configure --prefix=${WRF_INSTALL}/jasper
make -j$(nproc) install

################## INSTALL WPS ################################################

cd $DOWNLOAD
curl -o WPS-v4.2.tar.gz -J -L https://github.com/wrf-model/WPS/archive/refs/tags/v4.2.tar.gz

tar -xzvf WPS-v4.2.tar.gz -C ${WRF_INSTALL}
cd ${WRF_INSTALL}/WPS-4.2
