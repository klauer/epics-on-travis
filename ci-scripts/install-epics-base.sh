#!/bin/bash
set -e -x

source $CI_SCRIPTS/epics-config.sh

# EPICS V3

build_epics_base() {
    BUILD_DIR=$EPICS_BUILD_ROOT/base
    mkdir -p $BUILD_DIR

    if [ ! -d $BUILD_DIR/configure ]; then
        git clone --depth=1 --recursive --branch ${BASE_VER} https://github.com/epics-base/epics-base.git $BUILD_DIR
    fi

    ( cd $BUILD_DIR && git pull && git checkout $BASE_VER );

    EPICS_HOST_ARCH=`sh $BUILD_DIR/startup/EpicsHostArch`

    case "$STATIC_BUILD" in
    YES)
        cat << EOF >> "$BUILD_DIR/configure/CONFIG_SITE"
SHARED_LIBRARIES=NO
STATIC_BUILD=YES
EOF
        ;;
    *) ;;
    esac
    
    # Disable building with readline
    sed -i -e "s/^COMMANDLINE_LIBRARY\s*=\s*READLINE//" $BUILD_DIR/configure/os/CONFIG_SITE*

    make -C "$BUILD_DIR" -j$(expr $(nproc) + 1) INSTALL_LOCATION=$EPICS_BASE

    # get MSI for 3.14
    case "$BASE_VER" in
    R3.14*)
        echo "Build MSI"
        MSI_BUILD_DIR=$EPICS_BUILD_ROOT/msi
        install -d "$MSI_BUILD_DIR/extensions/src"
        curl -L https://github.com/epics-extensions/extensions/archive/extensions_20120904.tar.gz | tar --strip-components 1 -C "$MSI_BUILD_DIR/extensions" -xvz
        curl https://epics.anl.gov/download/extensions/msi1-7.tar.gz | tar -C "$MSI_BUILD_DIR/extensions/src" -xvz
        mv "$MSI_BUILD_DIR/extensions/src/msi1-7" "$MSI_BUILD_DIR/extensions/src/msi"

        cat << EOF > "$MSI_BUILD_DIR/extensions/configure/RELEASE"
EPICS_BASE=$EPICS_BASE
EPICS_EXTENSIONS=\$(TOP)
EOF
        make -C "$MSI_BUILD_DIR/extensions"

        bin_path="$EPICS_BASE/bin/$EPICS_HOST_ARCH/"
        chmod u+w $bin_path
        cp "$MSI_BUILD_DIR/extensions/bin/$EPICS_HOST_ARCH/msi" $bin_path

        chmod u+w "$EPICS_BASE/configure/CONFIG_SITE"
        echo 'MSI:=$(EPICS_BASE)/bin/$(EPICS_HOST_ARCH)/msi' >> "$EPICS_BASE/configure/CONFIG_SITE"
        
        # TODO: correct config_site?
        cat <<EOF >> ${EPICS_BASE}/CONFIG_SITE
MSI = \$(EPICS_BASE)/bin/\$(EPICS_HOST_ARCH)/msi
EOF

      ;;
    *) echo "Use MSI from Base"
      ;;
    esac
    
    make -C "$BUILD_DIR" INSTALL_LOCATION=$EPICS_BASE

    # TODO: for some reason, startup scripts are not installed
    install -d $EPICS_BASE/startup
    cp -R $BUILD_DIR/startup/* $EPICS_BASE/startup

    # Also put the useful EpicsHostArch scripts in bin
    cp $BUILD_DIR/startup/EpicsHostArch* $EPICS_BASE/bin/$EPICS_HOST_ARCH
    chmod +x $EPICS_BASE/bin/$EPICS_HOST_ARCH/EpicsHostArch*

    touch $EPICS_BASE/built
}

# EPICS V7

build_epics7() {
    BUILD_DIR=$EPICS_BUILD_ROOT/base
    mkdir -p $BUILD_DIR

    if [ ! -d $BUILD_DIR/configure ]; then
        git clone --depth=1 --shallow-submodules --recursive --branch ${BASE_VER} https://github.com/epics-base/epics-base.git $BUILD_DIR
    fi

    ( cd $BUILD_DIR && git pull && git checkout $BASE_VER );

    EPICS_HOST_ARCH=`sh $BUILD_DIR/startup/EpicsHostArch`

    case "$STATIC_BUILD" in
    YES)
        sed -i -e "s/^STATIC_BUILD=.*/STATIC_BUILD=YES/" $BUILD_DIR/configure/CONFIG_SITE
        ;;
    *) 
        sed -i -e "s/^STATIC_BUILD=.*/STATIC_BUILD=NO/" $BUILD_DIR/configure/CONFIG_SITE
        ;;
    esac

    make -C "$BUILD_DIR" -j$(expr $(nproc) + 1) INSTALL_LOCATION=$EPICS_BASE COMMANDLINE_LIBRARY=EPICS

    if [ ! -d $EPICS_BASE/startup ]; then
        # TODO: for some reason, startup scripts are not installed
        install -d $EPICS_BASE/startup
        cp -R $BUILD_DIR/startup/* $EPICS_BASE/startup
    fi

    if [ ! -f $EPICS_BASE/bin/$EPICS_HOST_ARCH/EpicsHostArch ]; then
        # Also put the useful EpicsHostArch scripts in bin
        cp $BUILD_DIR/startup/EpicsHostArch* $EPICS_BASE/bin/$EPICS_HOST_ARCH
        chmod +x $EPICS_BASE/bin/$EPICS_HOST_ARCH/EpicsHostArch*
    fi
    
    # copy pva2pva IOCs over
    install -d $IOCS/pva2pva
    cp -R $BUILD_DIR/modules/pva2pva/iocBoot $IOCS/pva2pva/

    touch $EPICS_BASE/built

}


if [ ! -e "$EPICS_BASE/built" ]
then
    case "$BASE_VER" in
    R3*)
        build_epics_base
        ;;
    R7*)
        build_epics7
        ;;
    esac
else
    echo "Using cached epics-base!"
fi
