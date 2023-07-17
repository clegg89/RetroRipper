# Adapted from https://github.com/ObKo/stm32-cmake
#[=======================================================================[.md:
FindCMSIS
=========

Generate imported libraries for CMSIS for requested families/devices. At
this time only STM32 famlies/devices are supported.

In the context of STM32, a Family is equivalent to what ST calls a "product
line." Examples include STM32H7, STM32F1, etc.

Devices are the full device name, minus the package component, for example
the STM32F103RB.

ST's implementation of CMSIS adds a concept of 'types.' This is generally
a grouping of subsets (i.e. the series, Flash/RAM size, etc.) within a
given family. These types are shown as preprocessor definitions within
the CMSIS Device Header File (<device>.h).

Components
----------
The package accepts any valid family and/or device as a component.

Families should be given in the form of `STM32${FAMILY}`, and will
generate imported libraries for all valid types of the family.

Devices should be given in the form of `ST32${DEVICE}`, and will generate
only the imported libraries to support that device's type.

If no components are requested, all supported families/types will be
generated.

Imported Targets
----------------
Regardless of components requested, the package will create the
`CMSIS::STM32::CORE` target, which contains the include paths for the
version of CMSIS Core currently supported by ST.

Any additional families/types will get a family library:
`CMSIS::STM32::${FAMILY}`

and a type library:
`CMSIS::STM32::${TYPE}`

The type library links to the family library, which links to the core
library. The family library also links to the `FindSTM32` imported family
library.

For families with subfamilies, the subfamily will be added to the end of
both the family and type library names.

Utility Functions
-----------------
The library provides the following utility functions:
	* cmsis_stm32_get_family_types - Retrieve all valid types for a given
	  family.
	* cmsis_stm32_get_device_type - Retrive the type associated with a
	  device.
	* cmsis_stm32_get_type_subfamlies - Retrieve the subfamilies supported
	  by a given type.

Usage
-----
The Type library is intended to be linked with applications targets. Note
that any executable target is responsible for including their own startup
file, system configuration file, and linker script, as CMSIS/ST only
provide templates for these files.
See [the CMSIS documentation](https://arm-software.github.io/CMSIS_5/Core/html/using_pg.html)
for more information.
#]=======================================================================]

include("${CMAKE_CURRENT_LIST_DIR}/cmsis/devices.cmake")

if(NOT CMSIS_FIND_COMPONENTS)
    set(CMSIS_FIND_COMPONENTS ${STM32_SUPPORTED_FAMILIES_LONG_NAMES})
endif()

list(REMOVE_DUPLICATES CMSIS_FIND_COMPONENTS)

message(STATUS "Search for CMSIS families: ${CMSIS_FIND_COMPONENTS}")

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

foreach(COMP ${CMSIS_FIND_COMPONENTS})
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
		foreach(SUBFAMILY ${SUBFAMILIES})
			if(${SUBFAMILY} STREQUAL "")
				set(SUBFAMILY_C "")
			else()
			 	string(TOUPPER ${SUBFMAILY} SUBFAMILY)
				set(SUBFAMILY_C "::${SUBFAMILY}")

				_cmsis_stm32_get_subfamily_definitions(${FAMILY} ${SUBFAMILY} SUBFAMILY_DEFINITIONS)
			endif()

			# Create family library if it does not already exist
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

			# Create type library
			if(NOT (TARGET CMSIS::STM32::${TYPE}::${SUBFAMILY}))
				message(TRACE "FindCMSIS: creating library CMSIS::STM32::${TYPE}${SUBFAMILY_C}")
				add_library(CMSIS::STM32::${TYPE}${SUBFAMILY_C} INTERFACE IMPORTED)
				target_link_libraries(CMSIS::STM32::${TYPE}${SUBFAMILY_C} INTERFACE CMSIS::STM32::${FAMILY}${SUBFAMILY_C})
				target_compile_definitions(CMSIS::STM32::${TYPE}${SUBFAMILY_C} INTERFACE STM32${TYPE})
			endif()
		endforeach()
	endforeach()
    list(REMOVE_DUPLICATES CMSIS_INCLUDE_DIRS)
endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CMSIS
    REQUIRED_VARS CMSIS_INCLUDE_DIRS
    HANDLE_COMPONENTS
)
