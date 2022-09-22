#!/bin/bash -i
. /etc/parallelcluster/cfnconfig

shared_folder=$(echo $cfn_shared_dir | cut -d ',' -f 1 )


function create_env_file {
echo "Create Env"
cat <<@EOF >${shared_folder}/setup_env.sh
#!/bin/bash
export DOWNLOAD=${shared_folder}/tools
export WRF_INSTALL=${shared_folder}/wrf-arm
export WRF_DIR=${WRF_INSTALL}/WRF-4.2.2
export GCC_VERSION=10.2.0
export OPENMPI_VERSION=4.1.0
export PATH=${WRF_INSTALL}/gcc-${GCC_VERSION}/bin:$PATH
export LD_LIBRARY_PATH=${WRF_INSTALL}/gcc-${GCC_VERSION}/lib64:$LD_LIBRARY_PATH
export CC=gcc
export CXX=g++
export FC=gfortran
export PATH=${WRF_INSTALL}/openmpi-${OPENMPI_VERSION}/bin:$PATH
export LD_LIBRARY_PATH=${WRF_INSTALL}/openmpi-${OPENMPI_VERSION}/lib:$LD_LIBRARY_PATH
export CC=mpicc
export CXX=mpic++
export FC=mpifort
export F90=mpifort
export CXX=mpicxx
export FC=mpif90
export F77=mpif90
export F90=mpif90
export CFLAGS="-g -O2 -fPIC"
export CXXFLAGS="-g -O2 -fPIC"
export FFLAGS="-g -fPIC -fallow-argument-mismatch"
export FCFLAGS="-g -fPIC -fallow-argument-mismatch"
export FLDFLAGS="-fPIC"
export F90LDFLAGS="-fPIC"
export LDFLAGS="-fPIC"
export HDF5=${WRF_INSTALL}/hdf5
export PNET=${WRF_INSTALL}/pnetcdf
export ZLIB=${WRF_INSTALL}/zlib
export CPPFLAGS="-I$HDF5/include -I${PNET}/include"
export CFLAGS="-I$HDF5/include -I${PNET}/include"
export CXXFLAGS="-I$HDF5/include -I${PNET}/include"
export FCFLAGS="-I$HDF5/include -I${PNET}/include"
export FFLAGS="-I$HDF5/include -I${PNET}/include"
export LDFLAGS="-I$HDF5/include -I${PNET}/include -L$ZLIB/lib -L$HDF5/lib -L${PNET}/lib"
export NCDIR=${WRF_INSTALL}/netcdf
export LD_LIBRARY_PATH=${NCDIR}/lib:${LD_LIBRARY_PATH}
export CPPFLAGS="-I$HDF5/include -I$NCDIR/include"
export CFLAGS="-I$HDF5/include -I$NCDIR/include"
export CXXFLAGS="-I$HDF5/include -I$NCDIR/include"
export FCFLAGS="-I$HDF5/include -I$NCDIR/include"
export FFLAGS="-I$HDF5/include -I$NCDIR/include"
export LDFLAGS="-L$HDF5/lib -L$NCDIR/lib"
export PHDF5=${WRF_INSTALL}/hdf5
export NETCDF=${WRF_INSTALL}/netcdf
export PNETCDF=${WRF_INSTALL}/pnetcdf
export PATH=${WRF_INSTALL}/netcdf/bin:${PATH}
export PATH=${WRF_INSTALL}/pnetcdf/bin:${PATH}
export PATH=${WRF_INSTALL}/hdf5/bin:${PATH}
export LD_LIBRARY_PATH=${WRF_INSTALL}/netcdf/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${WRF_INSTALL}/pnetcdf/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${WRF_INSTALL}/hdf5/lib:$LD_LIBRARY_PATH
export WRFIO_NCD_LARGE_FILE_SUPPORT=1
export NETCDF_classic=1
export F77=mpifort
export FFLAGS="-g -fPIC"
export FCFLAGS="-g -fPIC"
export JASPERLIB=${WRF_INSTALL}/jasper/lib
export JASPERINC=${WRF_INSTALL}/jasper/include

@EOF

chmod 777 ${shared_folder}
chmod 755 ${shared_folder}/setup_env.sh
}

echo "NODE TYPE: ${cfn_node_type}"

case ${cfn_node_type} in
        MasterServer)
                echo "I am Master node"
                create_env_file
                source ${shared_folder}/setup_env.sh
                cd wrf_setup_scripts
                /bin/su ec2-user -c "/bin/bash -i compile_and_install.sh"
                /bin/su ec2-user -c "/bin/bash -i build_dir.sh"

        ;;
        ComputeFleet)
                echo "I am a Compute node"
        ;;
        esac
