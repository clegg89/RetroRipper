# Adapted from https://github.com/ObKo/stm32-cmake
#[=======================================================================[.md:
FindSTM32
=========

Generate imported libraries for one or more families of the STM32 product
line from ST Microelectronics.

Components
----------
The caller may provide one or more families to generate libraries for.
Components should be in the format `${FAMILY}` where family is one of
the valid supported STM32 families.

If no components are specified, imported libraries for all the supported
families are created.

Imported Targets
----------------
Each family that is requested will have a single imported library of the
format `STM32::${FAMILY}`. The target does contain any source code, but
instead adds compiler and linker options (including predefines) to
properly compile source code for the chosen family.

Some families have subfamilies, for example: multi-core product lines and
product lines which come with varying FPU support. In these cases, the
targets created are `STM32::${FAMILY}::${SUBFAMILY}.

Usage
-----
In general this package is not meant to be used or linked to directly.
Instead it is meant to be used by other packages (i.e. FindCMSIS) as an
intermediate step to provide proper compiler/linker options.
#]=======================================================================]


## Create interface libraries for a given STM32 series
#
# This function takes inputs describing an STM32 family
# and creates the appropriate interface libraries for the
# family and its supported types.
#
# The caller is responsible for adding core-specific flags
# to the generated family target after calling.
#
# FAMILY - The family to create the targets for
# SUBFAMILY - Optional. Some STM32 families can be subdivided, i.e.
# multi-core targets (M7) or famililes that support different FPU
# definitions. This field will append to the family (i.e. STM32::H7::M7)
# but will still define the family/type in the definitions section.
# TYPES - Full list of supported types
function(_stm32_create_family_targets)
	set(ARG_OPTIONS "")
	set(ARG_SINGLE FAMILY SUBFAMILY)
	set(ARG_MULTIPLE "")
	cmake_parse_arguments(ARG "${ARG_OPTIONS}" "${ARG_SINGLE}" "${ARG_MULTIPLE}" ${ARGN})

	if(ARG_SUBFAMILY)
		string(TOUPPER "${ARG_SUBFAMILY}" SUBFAMILY)
		set(SUBFAMILY_C "::${SUBFAMILY}")
	else()
		set(SUBFAMILY "")
		set(SUBFAMILY_C "")
	endif()

	if (NOT (TARGET STM32::${ARG_FAMILY}${SUBFAMILY_C}))
		add_library(STM32::${ARG_FAMILY}${SUBFAMILY_C} INTERFACE IMPORTED)
		# Set compiler flags for target
		# -Wall: all warnings activated
		# -ffunction-sections -fdata-sections: remove unused code
		target_compile_options(STM32::${ARG_FAMILY}${SUBFAMILY_C} INTERFACE
			$<$<C_COMPILER_ID:GNU>:-mthumb>
			$<$<C_COMPILER_ID:GNU>:-Wall>
			$<$<C_COMPILER_ID:GNU>:-ffunction-sections>
			$<$<C_COMPILER_ID:GNU>:-fdata-sections>
			$<$<AND:$<C_COMPILER_ID:GNU>,$<CONFIG:Debug>>:-g>
		)
		# Set linker flags
		# -mthumb: Generate thumb code
		# -Wl,--gc-sections: Remove unused code
		target_link_options(STM32::${ARG_FAMILY}${SUBFAMILY_C} INTERFACE
			$<$<C_COMPILER_ID:GNU>:-mthumb>
			$<$<C_COMPILER_ID:GNU>:--Wl,--gc-sections>
		)
		target_compile_definitions(STM32::${ARG_FAMILY}${SUBFAMILY_C} INTERFACE
			STM32${ARG_FAMILY}
		)
	endif()
endfunction()

# Currently missing: c0 h5 wba
set(STM32_SUPPORTED_FAMILIES
	# Mainstream
	f0 g0 f1 f3 g4
	# Ultra-low-power
	l0 l4 l5 u5
	# High Performance
	f2 f4 f7 h7
	# Wireless
	wl wb
)

if(NOT STM32_FIND_COMPONENTS)
	set(STM32_FIND_COMPONENTS ${STM32_SUPPORTED_FAMILIES})
endif()

list(REMOVE_DUPLICATES STM32_FIND_COMPONENTS)

message(STATUS "Search for STM32 families: ${STM32_FIND_COMPONENTS}")

foreach(FAMILY ${STM32_FIND_COMPONENTS})
	string(TOLOWER ${FAMILY} FAMILY)

	if(NOT (${FAMILY} IN_LIST STM32_SUPPORTED_FAMILIES))
		message(WARNING "Invalid/unsupported STM32 FAMILY ${FAMILY}")
		continue()
	endif()

	find_file(FAMILY_INCLUDE
		"${FAMILY}.cmake"
		PATHS "${CMAKE_CURRENT_LIST_DIR}/stm32/families"
		NO_CMAKE_PATH
		REQUIRED
	)

	include("${FAMILY_INCLUDE}")
endforeach()

if(NOT (TARGET STM32::NoSys))
    add_library(STM32::NoSys INTERFACE IMPORTED)
    target_compile_options(STM32::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
    target_link_options(STM32::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
endif()

if(NOT (TARGET STM32::Nano))
    add_library(STM32::Nano INTERFACE IMPORTED)
    target_compile_options(STM32::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
    target_link_options(STM32::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
endif()

if(NOT (TARGET STM32::Nano::FloatPrint))
    add_library(STM32::Nano::FloatPrint INTERFACE IMPORTED)
    target_link_options(STM32::Nano::FloatPrint INTERFACE
        $<$<C_COMPILER_ID:GNU>:-Wl,--undefined,_printf_float>
    )
endif()

if(NOT (TARGET STM32::Nano::FloatScan))
    add_library(STM32::Nano::FloatScan INTERFACE IMPORTED)
    target_link_options(STM32::Nano::FloatScan INTERFACE
        $<$<C_COMPILER_ID:GNU>:-Wl,--undefined,_scanf_float>
    )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(STM32
	HANDLE_COMPONENTS
)
