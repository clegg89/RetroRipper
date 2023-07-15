# Adapted from https://github.com/ObKo/stm32-cmake
# Generate imported CMSIS libraries for requested STM32
# families and device types. (Only STM32 is supported at
# this time, though future vendors could be added)
#
# The CMSIS family libraries provide the proper include paths
# for both the CMSIS Core and Device library. They will also
# link to the corresponding STM32 family library.
#
# The CMSIS type libraries simply add the appropriate
# preprocessor definiton, which will result in the proper Device
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
#   * STM32 Family - All types of the family are generated
#   * STM32 Device - The family and type of the device are generated
#
# Multiple devices/families can be specified, and mixed and matched.
# STM32 types are not supported, only the full device name or the
# entire family are supported components.
#
# Note that each application (i.e. executable) is responsible for
# including their own startup files, system configuration files,
# and linker script, as CMSIS/STM32 only provide templates for these
# files. See https://arm-software.github.io/CMSIS_5/Core/html/using_pg.html
# for more details.

include("${CMAKE_CURRENT_LIST_DIR}/cmsis/devices.cmake")

foreach(FAMILY ${CMSIS_SUPPORTED_FAMILIES})
	string(TOUPPER "${FAMILY}" FAMILY_U)
	list(APPEND SUPPORTED_FAMILIES_LONG_NAME "STM32${FAMILY_U}")
endforeach()

if(NOT CMSIS_FIND_COMPONENTS)
    set(CMSIS_FIND_COMPONENTS ${SUPPORTED_FAMILIES_LONG_NAME})
endif()

list(REMOVE_DUPLICATES CMSIS_FIND_COMPONENTS)

message(STATUS "Search for CMSIS families: ${CMSIS_FIND_COMPONENTS_FAMILIES}")

# CMSIS::STM32::CORE target is always created/required
# TODO: Versioning? use actual CMSIS_5 Core?
find_path(CMSIS_CORE_PATH
	NAMES Include/cmsis_gcc.h # Actual toolchain doesn't matter, we're just looking for the include path
	PATHS "${CMAKE_CURRENT_LIST_DIR}/../submodules/stm32"
	NO_DEFAULT_PATH
)
if (NOT CMSIS_CORE_PATH)
	if (CMSIS_FIND_REQUIRED)
		message(FATAL_ERROR "Cannot find CMSIS Core")
	endif()
	# TODO: Handle other cases??
endif()
list(APPEND CMSIS_INCLUDE_DIRS "${CMSIS_CORE_PATH}/Include")

if(NOT (TARGET CMSIS::STM32::CORE))
	add_library(CMSIS::STM32::CORE INTERFACE IMPORTED)
	target_include_directories(CMSIS::STM32::CORE INTERFACE "${CMSIS_CORE_PATH}/Include")
endif()

function(_cmsis_create_targets)
	set(ARG_OPTIONS "")
	set(ARG_SINGLE FAMILY TYPE SUBFAMILY)
	set(ARG_MULTIPLE "")
	cmake_parse_arguments(ARG "${ARG_OPTIONS}" "${ARG_SINGLE}" "${ARG_MULTIPLE}" ${ARGN})

	if(NOT ARG_FAMILY OR NOT ARG_TYPE)
		message(FATAL_ERROR "FAMILY and TYPE arguments are required")
	endif()

	if(ARG_SUBFAMILY)
		cmsis_stm32_get_subfamily_definitions(${ARG_FAMILY} ${ARG_SUBFAMILY} SUBFAMILY_DEFINITIONS)
		set(SUBFAMILY_C "::${ARG_SUBFAMILY}")
	else()
		set(SUBFAMILY_C "")
	endif()

	if(NOT (TARGET CMSIS::STM32::${FAMILY})${SUBFAMILY_C})
		message(TRACE "FindCMSIS: creating library CMSIS::STM32::${FAMILY}${SUBFAMILY_C}")
		add_library(CMSIS::STM32::${FAMILY}${SUBFAMILY_C} INTERFACE IMPORTED)
		target_link_libraries(CMSIS::STM32::${FAMILY}${SUBFAMILY_C} INTERFACE
			STM32::${FAMILY}${SUBFAMILY_C}
			CMSIS::STM32::CORE)
		target_include_directories(CMSIS::STM32::${FAMILY}${SUBFAMILY_C} INTERFACE "${CMSIS_${FAMILY}_PATH}/Include")
		if(SUBFAMILY_DEFINITIONS)
			target_compile_definitions(CMSIS::STM32::${FAMILY}${SUBFAMILY_C} INTERFACE ${SUBFAMILY_DEFINITIONS})
		endif()
	endif()
	if(NOT (TARGET CMSIS::STM32::${TYPE}::${SUBFAMILY}))
		message(TRACE "FindCMSIS: creating library CMSIS::STM32::${TYPE}${SUBFAMILY_C}")
		add_library(CMSIS::STM32::${TYPE}${SUBFAMILY_C} INTERFACE IMPORTED)
		target_link_libraries(CMSIS::STM32::${TYPE}${SUBFAMILY_C} INTERFACE CMSIS::STM32::${FAMILY}${SUBFAMILY_C})
		target_compile_definitions(CMSIS::STM32::${TYPE}${SUBFAMILY_C} INTERFACE STM32${TYPE})
	endif()
endfunction()

foreach(COMP ${CMSIS_FIND_COMPONENTS_FAMILIES})
    string(TOLOWER ${COMP} COMP_L)
    string(TOUPPER ${COMP} COMP)

	# REGEX to match possible STM32 components
	# MATCH1 should always hit, and indicates the Family (i.e. F1, WB, MP1, etc.)
	# MATCH2 is the full device info (i.e. 03RB), MATCH1 + MATCH2 are the full device: F103RB
    string(REGEX MATCH "^STM32([FGHLMUW]P?[0-9BL])([0-9A-Z][0-9M][A-Z][0-9A-Z])?.*$" COMP ${COMP})
    # CMAKE_MATCH_<n> contains n'th subexpression
    # CMAKE_MATCH_0 contains full match

    if(NOT CMAKE_MATCH_1)
        message(FATAL_ERROR "Unknown CMSIS component: ${COMP}")
    endif()
    
	set(FAMILY ${CMAKE_MATCH_1})

    if(CMAKE_MATCH_2)
		# Full Device name
		cmsis_stm32_get_device_type("${FAMILY}${CMAKE_MATCH_2}" STM_TYPES)
        message(TRACE "FindCMSIS: full device name match for COMP ${COMP}, STM_TYPES is ${STM_TYPES}")

    else()
		# Entire family
		cmsis_stm32_get_family_types(${FAMILY} STM_TYPES)
        message(TRACE "FindCMSIS: family only match for COMP ${COMP}, STM_TYPES is ${STM_TYPES}")
    endif()

    string(TOLOWER ${FAMILY} FAMILY_L)

	if (NOT CMSIS_${FAMILY}_PATH)
		# Search for Include/stm32[XX]xx.h
		find_path(CMSIS_${FAMILY}_PATH
			NAMES Include/stm32${FAMILY_L}xx.h
			PATHS "${CMAKE_CURRENT_LIST_DIR}/../submodules/stm32"
			NO_DEFAULT_PATH
		)
		if (NOT CMSIS_${FAMILY}_PATH)
			message(VERBOSE "FindCMSIS: stm32${FAMILY_L}xx.h for ${FAMILY} has not been found")
			continue()
		endif()
	endif()

	foreach(TYPE ${STM_TYPES})
		cmsis_stm32_get_type_subfamilies(${TYPE} SUBFAMILIES)

		if(SUBFAMILIES)
			foreach(SUBFAMILY ${SUBFAMILIES})
				_cmsis_create_targets(FAMILY ${FAMILY} TYPE ${TYPE} SUBFAMILY ${SUBFAMILY})
			endforeach()
		else()
			_cmsis_create_targets(FAMILY ${FAMILY} TYPE ${TYPE})
		endif()
	endforeach()
    list(REMOVE_DUPLICATES CMSIS_INCLUDE_DIRS)
endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CMSIS
    REQUIRED_VARS CMSIS_INCLUDE_DIRS
    FOUND_VAR CMSIS_FOUND
    HANDLE_COMPONENTS
)
