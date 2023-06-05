# change from xLua

cmake_minimum_required(VERSION 2.8.12)

if ( WIN32 AND NOT CYGWIN AND NOT ( CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" ) AND NOT ANDROID)
	set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT" CACHE STRING "")
	set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /MTd" CACHE STRING "")
	set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MT" CACHE STRING "")
	set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MTd" CACHE STRING "")
endif ()

project(tolua)

if ( IOS )
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fembed-bitcode")
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fembed-bitcode")
endif ()

option ( USING_LUAJIT "using luajit" ON )
option ( LUAC_COMPATIBLE_FORMAT "compatible format" OFF )
option ( CJSON "using lua-cjson" OFF )

find_path(TOLUA_PROJECT_DIR NAMES SConstruct
    PATHS 
    ${CMAKE_SOURCE_DIR}
    NO_DEFAULT_PATH
    )

MARK_AS_ADVANCED(TOLUA_PROJECT_DIR)

if (NOT LUA_VERSION)
    set(LUA_VERSION "5.1.5")
endif()

set(LUA_SRC_PATH lua-${LUA_VERSION}/src)
set(LUAJIT_SRC_PATH luajit2/src)


 #begin pbc
 set (PBC_SRC
     pbc/src/alloc.c
     pbc/src/array.c
     pbc/src/bootstrap.c
     pbc/src/context.c
     pbc/src/decode.c
     pbc/src/map.c
     pbc/src/pattern.c
     pbc/src/proto.c
     pbc/src/register.c
     pbc/src/rmessage.c
     pbc/src/stringpool.c
     pbc/src/varint.c
     pbc/src/wmessage.c
 )
 
 #if (USING_LUAJIT)
 #    list(APPEND PBC_SRC pbc pbc/binding/lua/pbc-lua.c)
 #else ()
 #    list(APPEND PBC_SRC pbc pbc/binding/lua53/pbc-lua53.c)
 #endif ()
 list(APPEND PBC_SRC pbc pbc/binding/lua/pbc-lua.c)
 
 set_property(
     SOURCE ${PBC_SRC}
     APPEND
     PROPERTY COMPILE_DEFINITIONS
     LUA_LIB
 )
 list(APPEND THIRDPART_INC pbc pbc/src)
 set (THIRDPART_SRC ${THIRDPART_SRC} ${PBC_SRC})
 #end pbc

if (NOT CJSON)
    #begin lua-rapidjson
    set (RAPIDJSON_SRC
        #lua-rapidjson/src/Document.cpp
        #lua-rapidjson/src/Schema.cpp
        lua-rapidjson/src/rapidjson.cpp
    )
    set_property(
        SOURCE ${RAPIDJSON_SRC}
        APPEND
        PROPERTY COMPILE_DEFINITIONS
        LUA_LIB
    )
    list(APPEND THIRDPART_INC lua-rapidjson/rapidjson/include)
    set (THIRDPART_SRC ${THIRDPART_SRC} ${RAPIDJSON_SRC})
    #end lua-rapidjson
else()
    #begin lua-cjson
    set (CJSON_SRC
        lua-cjson/fpconv.c
        lua-cjson/strbuf.c
        lua-cjson/lua_cjson.c
    )
    set_property(
        SOURCE ${CJSON_SRC}
        APPEND
        PROPERTY COMPILE_DEFINITIONS
        LUA_LIB
    )
    list(APPEND THIRDPART_INC lua-cjson)
    set (THIRDPART_SRC ${THIRDPART_SRC} ${CJSON_SRC})
    #end lua-cjson
endif ()

#begin lpeg
set (LPEG_SRC
    lpeg/lpcap.c
    lpeg/lpcode.c
    lpeg/lpprint.c
    lpeg/lptree.c
    lpeg/lpvm.c
)
set_property(
    SOURCE ${LPEG_SRC}
    APPEND
    PROPERTY COMPILE_DEFINITIONS
    LUA_LIB
)
list(APPEND THIRDPART_INC lpeg)
set (THIRDPART_SRC ${THIRDPART_SRC} ${LPEG_SRC})
#end lpeg

if (USING_LUAJIT)
	
    if (APPLE AND NOT IOS AND NOT ANDROID)
        set ( LUA_IDSIZE 120 CACHE STRING "gives the maximum size for the description of the source." )
	    configure_file ( lua-5.1.5/src/luaconf.h.in ${CMAKE_CURRENT_BINARY_DIR}/luaconf.h )
	    include_directories(
		  ${CMAKE_SOURCE_DIR}
		  lua-5.1.5/src
		  lua-5.1.5/etc
		  ${CMAKE_CURRENT_BINARY_DIR}
		  ${THIRDPART_INC}
	    )
	    set ( LUA_CORE lua-5.1.5/src/lapi.c lua-5.1.5/src/lcode.c lua-5.1.5/src/ldebug.c lua-5.1.5/src/ldo.c lua-5.1.5/src/ldump.c lua-5.1.5/src/lfunc.c 
          lua-5.1.5/src/lgc.c lua-5.1.5/src/llex.c lua-5.1.5/src/lmem.c lua-5.1.5/src/lobject.c lua-5.1.5/src/lopcodes.c lua-5.1.5/src/lparser.c lua-5.1.5/src/lstate.c 
          lua-5.1.5/src/lstring.c lua-5.1.5/src/ltable.c lua-5.1.5/src/ltm.c lua-5.1.5/src/lundump.c lua-5.1.5/src/lvm.c lua-5.1.5/src/lzio.c lua-5.1.5/src/lauxlib.c 
          lua-5.1.5/src/lbaselib.c lua-5.1.5/src/ldblib.c lua-5.1.5/src/liolib.c lua-5.1.5/src/lmathlib.c lua-5.1.5/src/loslib.c lua-5.1.5/src/ltablib.c 
          lua-5.1.5/src/lstrlib.c lua-5.1.5/src/linit.c lua-5.1.5/src/loadlib.c)
	else ()
	    include_directories(
		  ${CMAKE_SOURCE_DIR}
		  ${LUAJIT_SRC_PATH}
		  ${CMAKE_CURRENT_BINARY_DIR}
		  ${THIRDPART_INC}
	    )

	    set ( LUA_CORE )
	    set_property( SOURCE tolua.c APPEND PROPERTY COMPILE_DEFINITIONS USING_LUAJIT )
    endif ()
	set ( LUA_LIB )
else ()
	set ( LUA_IDSIZE 120 CACHE STRING "gives the maximum size for the description of the source." )

	configure_file ( ${LUA_SRC_PATH}/luaconf.h.in ${CMAKE_CURRENT_BINARY_DIR}/luaconf.h )

	include_directories(
	    ${CMAKE_SOURCE_DIR}
		${LUA_SRC_PATH}
		${CMAKE_CURRENT_BINARY_DIR}
		${THIRDPART_INC}
	)

    aux_source_directory(${LUA_SRC_PATH} LUA_CORE)
    list(REMOVE_ITEM LUA_CORE ${LUA_SRC_PATH}/lua.c ${LUA_SRC_PATH}/luac.c)
	set ( LUA_LIB )
endif ()

set ( LUA_SOCKET
    luasocket/src/auxiliar.c
    luasocket/src/buffer.c
    luasocket/src/compat.c
    luasocket/src/except.c
    luasocket/src/inet.c
    luasocket/src/io.c
    luasocket/src/luasocket.c
    luasocket/src/mime.c
    luasocket/src/options.c
    luasocket/src/select.c
    luasocket/src/tcp.c
    luasocket/src/timeout.c
    luasocket/src/udp.c 
)

if ( WIN32 AND NOT CYGWIN )
    list (APPEND LUA_SOCKET luasocket/src/wsocket.c)
else ( )
    list (APPEND LUA_SOCKET luasocket/src/usocket.c)
endif ( )

set ( TOLUA_CORE
    int64.c
    uint64.c
    #pb.c
    struct.c
    tolua.c
)

if (NOT USING_LUAJIT)
    list (APPEND TOLUA_CORE bit.c)
else ( )
    if (APPLE AND NOT IOS AND NOT ANDROID)
        list (APPEND TOLUA_CORE bit.c)
    endif ( )
endif ( )

macro(source_group_by_dir proj_dir source_files)
    if(MSVC OR APPLE)
        get_filename_component(sgbd_cur_dir ${proj_dir} ABSOLUTE)
        foreach(sgbd_file ${${source_files}})
			get_filename_component(sgbd_abs_file ${sgbd_file} ABSOLUTE)
            file(RELATIVE_PATH sgbd_fpath ${sgbd_cur_dir} ${sgbd_abs_file})
            string(REGEX REPLACE "\(.*\)/.*" \\1 sgbd_group_name ${sgbd_fpath})
            string(COMPARE EQUAL ${sgbd_fpath} ${sgbd_group_name} sgbd_nogroup)
            string(REPLACE "/" "\\" sgbd_group_name ${sgbd_group_name})
            if(sgbd_nogroup)
                set(sgbd_group_name "\\")
            endif(sgbd_nogroup)
            source_group(${sgbd_group_name} FILES ${sgbd_file})
        endforeach(sgbd_file)
    endif(MSVC OR APPLE)
endmacro(source_group_by_dir)

source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LUA_SOCKET)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LUA_CORE)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} LUA_LIB)
source_group_by_dir(${CMAKE_CURRENT_SOURCE_DIR} TOLUA_CORE)

if (APPLE)
    if (IOS)
        set(CMAKE_OSX_ARCHITECTURES "$(ARCHS_STANDARD)")
        add_library(tolua STATIC
           ${LUA_CORE}
           ${LUA_LIB}
           ${LUA_SOCKET}
           ${TOLUA_CORE}
           ${THIRDPART_SRC}
        )
		set_xcode_property (tolua IPHONEOS_DEPLOYMENT_TARGET "7.0" "all")
    else ()
        ADD_DEFINITIONS(-DLUA_USE_MACOSX) #osx platform emmylua debugger must have this option or can not load cpath
        if (BUILD_SILICON)
           set(CMAKE_OSX_ARCHITECTURES arm64)

            add_library(tolua SHARED
                ${LUA_CORE}
                ${LUA_LIB}
                ${LUA_SOCKET}
                ${TOLUA_CORE}
                ${THIRDPART_SRC}
            )
        else ()
            set(CMAKE_OSX_ARCHITECTURES "$(ARCHS_STANDARD_64_BIT)")
            add_library(tolua MODULE
                ${LUA_CORE}
                ${LUA_LIB}
                ${LUA_SOCKET}
                ${TOLUA_CORE}
                ${THIRDPART_SRC}
            )
            set_target_properties ( tolua PROPERTIES BUNDLE TRUE )
            #set_target_properties ( tolua PROPERTIES FRAMEWORK TRUE )
            #set_target_properties ( tolua PROPERTIES MACOSX_RPATH TRUE )
        endif ()
    endif ()
elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Switch")
    add_library(tolua STATIC
        ${LUA_CORE}
        ${LUA_LIB}
        ${TOLUA_CORE}
        ${THIRDPART_SRC}
    )
    target_compile_options(tolua PRIVATE -m64 -mcpu=cortex-a57+fp+simd+crypto+crc -fno-common -fno-short-enums -ffunction-sections -fdata-sections -fPIC -fms-extensions)
else ( )
    add_library(tolua SHARED
        ${LUA_CORE}
        ${LUA_LIB}
        ${LUA_SOCKET}
        ${TOLUA_CORE}
        ${THIRDPART_SRC}
    )
endif ( )

if ( WIN32 AND NOT CYGWIN )
    target_compile_definitions (tolua PRIVATE LUA_BUILD_AS_DLL LUA_LIB)
endif ( )

# if (NOGC64 AND USING_LUAJIT)
#     target_compile_definitions (tolua PRIVATE LUAJIT_DISABLE_GC64)
# endif ()

if (LUAC_COMPATIBLE_FORMAT AND NOT USING_LUAJIT)
    target_compile_definitions (tolua PRIVATE LUAC_COMPATIBLE_FORMAT)
endif ()

set_property(
	SOURCE ${LUA_SOCKET}
	APPEND
	PROPERTY COMPILE_DEFINITIONS
	LUA_COMPAT_APIINTCASTS LUA_LIB _CRT_SECURE_NO_WARNINGS _WINSOCK_DEPRECATED_NO_WARNINGS
)

if(UINT_ESPECIALLY)
    ADD_DEFINITIONS(-DUINT_ESPECIALLY)
endif()
	
if ( WIN32 AND NOT CYGWIN )
    if (USING_LUAJIT)
        target_link_libraries(tolua
            ${CMAKE_SOURCE_DIR}/${LUAJIT_SRC_PATH}/lua51.lib
            ws2_32
            ${THIRDPART_LIB} 
        )
    else ()
        target_link_libraries(tolua
            ws2_32
            ${THIRDPART_LIB} 
        )
    endif()
else ( )
    if (USING_LUAJIT AND NOT APPLE)
		target_link_libraries(tolua
			${CMAKE_SOURCE_DIR}/${LUAJIT_SRC_PATH}/libluajit.a
			m
            ${THIRDPART_LIB} 
		)
    else ()
        target_link_libraries(tolua
            m
            ${THIRDPART_LIB} 
        )
    endif()
endif ( )
