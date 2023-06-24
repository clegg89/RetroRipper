# Adapted from https://github.com/ObKo/stm32-cmake
# Generate imported CMSIS libraries for requested STM32
# families and device types. (Only STM32 is supported at
# this time, though future vendors could be added)
#
# The CMSIS family libraries provide the proper include paths
# for both the CMSIS Core and Device library. They will also
# link to the corresponding STM32 family library.
#
# The CMSIS type libraries simply link to the corresponding
# STM32 type library, which will result in the proper Device
# Header File (<device>.h) being included. The source files
# included by the original cmake files are not included here,
# as these files were meant to be used as templates, not common
# source files.
# 
# The "Device" library added by the original are not included
# here, as each application is responsible for providing it's
# own linker script (see note below).
#
# The RTOS components/libraries included in the original are also
# not present, as they relied on files from STM32CubeXX and used
# the FreeRTOS files instead of the actual CMSIS files.
#
# Users of the library can specify components in the following ways:
#   * No components - All STM32 families and types are generated
#
# Note that each application (i.e. executable) is responsible for
# including their own startup files, system configuration files,
# and linker script, as CMSIS/STM32 only provide templates for these
# files. See https://arm-software.github.io/CMSIS_5/Core/html/using_pg.html
# for more details.

if(NOT CMSIS_FIND_COMPONENTS)
    set(CMSIS_FIND_COMPONENTS ${STM32_SUPPORTED_FAMILIES_LONG_NAME})
endif()

if(STM32H7 IN_LIST CMSIS_FIND_COMPONENTS)
    list(REMOVE_ITEM CMSIS_FIND_COMPONENTS STM32H7)
    list(APPEND CMSIS_FIND_COMPONENTS STM32H7_M7 STM32H7_M4)
endif()

if(STM32WB IN_LIST CMSIS_FIND_COMPONENTS)
    list(REMOVE_ITEM CMSIS_FIND_COMPONENTS STM32WB)
    list(APPEND CMSIS_FIND_COMPONENTS STM32WB_M4)
endif()

if(STM32WL IN_LIST CMSIS_FIND_COMPONENTS)
    list(REMOVE_ITEM CMSIS_FIND_COMPONENTS STM32WL)
    list(APPEND CMSIS_FIND_COMPONENTS STM32WL_M4 STM32WL_M0PLUS)
endif()

if(STM32MP1 IN_LIST CMSIS_FIND_COMPONENTS)
    list(REMOVE_ITEM CMSIS_FIND_COMPONENTS STM32MP1)
    list(APPEND CMSIS_FIND_COMPONENTS STM32MP1_M4)
endif()

list(REMOVE_DUPLICATES CMSIS_FIND_COMPONENTS)

if(NOT CMSIS_FIND_COMPONENTS_FAMILIES)
    set(CMSIS_FIND_COMPONENTS_FAMILIES ${STM32_SUPPORTED_FAMILIES_LONG_NAME})
endif()

message(STATUS "Search for CMSIS families: ${CMSIS_FIND_COMPONENTS_FAMILIES}")

foreach(COMP ${CMSIS_FIND_COMPONENTS_FAMILIES})
    string(TOLOWER ${COMP} COMP_L)
    string(TOUPPER ${COMP} COMP)
    
    string(REGEX MATCH "^STM32([FGHLMUW]P?[0-9BL])([0-9A-Z][0-9M][A-Z][0-9A-Z])?_?(M0PLUS|M4|M7)?.*$" COMP ${COMP})
    # CMAKE_MATCH_<n> contains n'th subexpression
    # CMAKE_MATCH_0 contains full match

    if((NOT CMAKE_MATCH_1) AND (NOT CMAKE_MATCH_2))
        message(FATAL_ERROR "Unknown CMSIS component: ${COMP}")
    endif()
    
    if(CMAKE_MATCH_2)
        set(FAMILY ${CMAKE_MATCH_1})
        set(STM_DEVICES "${CMAKE_MATCH_1}${CMAKE_MATCH_2}")
        message(TRACE "FindCMSIS: full device name match for COMP ${COMP}, STM_DEVICES is ${STM_DEVICES}")
    else()
        set(FAMILY ${CMAKE_MATCH_1})
        stm32_get_devices_by_family(STM_DEVICES FAMILY ${FAMILY})
        message(TRACE "FindCMSIS: family only match for COMP ${COMP}, STM_DEVICES is ${STM_DEVICES}")
    endif()
    
    if(CMAKE_MATCH_3)
        set(CORE ${CMAKE_MATCH_3})
        set(CORE_C "::${CORE}")
        set(CORE_U "_${CORE}")
        set(CORE_Ucm "_c${CORE}")
        string(TOLOWER ${CORE_Ucm} CORE_Ucm)
        message(TRACE "FindCMSIS: core match in component name for COMP ${COMP}. CORE is ${CORE}")
    else()
        unset(CORE)
        unset(CORE_C)
        unset(CORE_U)
        unset(CORE_Ucm)
    endif()
    
    string(TOLOWER ${FAMILY} FAMILY_L)
    
    if((NOT STM32_CMSIS_${FAMILY}_PATH) AND (NOT STM32_CUBE_${FAMILY}_PATH) AND (DEFINED ENV{STM32_CUBE_${FAMILY}_PATH}))
        # try to set path from environment variable. Note it could be ...-NOT-FOUND and it's fine
        set(STM32_CUBE_${FAMILY}_PATH $ENV{STM32_CUBE_${FAMILY}_PATH} CACHE PATH "Path to STM32Cube${FAMILY}")
        message(STATUS "ENV STM32_CUBE_${FAMILY}_PATH specified, using STM32_CUBE_${FAMILY}_PATH: ${STM32_CUBE_${FAMILY}_PATH}")
    endif()

    if((NOT STM32_CMSIS_${FAMILY}_PATH) AND (NOT STM32_CUBE_${FAMILY}_PATH))
        set(STM32_CUBE_${FAMILY}_PATH /opt/STM32Cube${FAMILY} CACHE PATH "Path to STM32Cube${FAMILY}")
        message(STATUS "Neither STM32_CUBE_${FAMILY}_PATH nor STM32_CMSIS_${FAMILY}_PATH specified using default STM32_CUBE_${FAMILY}_PATH: ${STM32_CUBE_${FAMILY}_PATH}")
    endif()
     
    # search for Include/cmsis_gcc.h
    find_path(CMSIS_${FAMILY}${CORE_U}_CORE_PATH
        NAMES Include/cmsis_gcc.h
        PATHS "${STM32_CMSIS_PATH}" "${STM32_CUBE_${FAMILY}_PATH}/Drivers/CMSIS"
        NO_DEFAULT_PATH
    )
    if (NOT CMSIS_${FAMILY}${CORE_U}_CORE_PATH)
        message(VERBOSE "FindCMSIS: cmsis_gcc.h for ${FAMILY}${CORE_U} has not been found")
        continue()
    endif()
	
    # search for Include/stm32[XX]xx.h
    find_path(CMSIS_${FAMILY}${CORE_U}_PATH
        NAMES Include/stm32${FAMILY_L}xx.h
        PATHS "${STM32_CMSIS_${FAMILY}_PATH}" "${STM32_CUBE_${FAMILY}_PATH}/Drivers/CMSIS/Device/ST/STM32${FAMILY}xx"
        NO_DEFAULT_PATH
    )
    if (NOT CMSIS_${FAMILY}${CORE_U}_PATH)
        message(VERBOSE "FindCMSIS: stm32${FAMILY_L}xx.h for ${FAMILY}${CORE_U} has not been found")
        continue()
    endif()
    list(APPEND CMSIS_INCLUDE_DIRS "${CMSIS_${FAMILY}${CORE_U}_CORE_PATH}/Include" "${CMSIS_${FAMILY}${CORE_U}_PATH}/Include")

    if(NOT CMSIS_${FAMILY}${CORE_U}_VERSION)
        find_file(CMSIS_${FAMILY}${CORE_U}_PDSC
            NAMES ARM.CMSIS.pdsc
            PATHS "${CMSIS_${FAMILY}${CORE_U}_CORE_PATH}"
            NO_DEFAULT_PATH
        )
        if (NOT CMSIS_${FAMILY}${CORE_U}_PDSC)
            set(CMSIS_${FAMILY}${CORE_U}_VERSION "0.0.0")
        else()
            file(STRINGS "${CMSIS_${FAMILY}${CORE_U}_PDSC}" VERSION_STRINGS REGEX "<release version=\"([0-9]*\\.[0-9]*\\.[0-9]*)\" date=\"[0-9]+\\-[0-9]+\\-[0-9]+\">")
            list(GET VERSION_STRINGS 0 STR)
            string(REGEX MATCH "<release version=\"([0-9]*)\\.([0-9]*)\\.([0-9]*)\" date=\"[0-9]+\\-[0-9]+\\-[0-9]+\">" MATCHED ${STR})
            set(CMSIS_${FAMILY}${CORE_U}_VERSION "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}.${CMAKE_MATCH_3}" CACHE INTERNAL "CMSIS STM32${FAMILY}${CORE_U} version")
        endif()
    endif()
    
    set(CMSIS_${COMP}_VERSION ${CMSIS_${FAMILY}${CORE_U}_VERSION})
    set(CMSIS_VERSION ${CMSIS_${COMP}_VERSION})

    if(NOT (TARGET CMSIS::STM32::${FAMILY}${CORE_C}))
        message(TRACE "FindCMSIS: creating library CMSIS::STM32::${FAMILY}${CORE_C}")
        add_library(CMSIS::STM32::${FAMILY}${CORE_C} INTERFACE IMPORTED)
        #STM32::${FAMILY}${CORE_C} contains compile options and is define in <family>.cmake
        target_link_libraries(CMSIS::STM32::${FAMILY}${CORE_C} INTERFACE STM32::${FAMILY}${CORE_C})
        target_include_directories(CMSIS::STM32::${FAMILY}${CORE_C} INTERFACE "${CMSIS_${FAMILY}${CORE_U}_CORE_PATH}/Include")
        target_include_directories(CMSIS::STM32::${FAMILY}${CORE_C} INTERFACE "${CMSIS_${FAMILY}${CORE_U}_PATH}/Include")
    endif()
    
    list(REMOVE_DUPLICATES CMSIS_INCLUDE_DIRS)
    list(REMOVE_DUPLICATES CMSIS_SOURCES)
endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CMSIS
    REQUIRED_VARS CMSIS_INCLUDE_DIRS CMSIS_SOURCES
    FOUND_VAR CMSIS_FOUND
    VERSION_VAR CMSIS_VERSION
    HANDLE_COMPONENTS
)
