# Adapted from https://github.com/ObKo/stm32-cmake
#[=======================================================================[.md:
FindSTM32
=========

Generate imported libraries for one or more families of the STM32 product
line from ST Microelectronics.

Components
----------
The caller may provide one or more families to generate libraries for.
Components should be in the format `STM32${FAMILY}` where family is one of
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

include("${CMAKE_CURRENT_LIST_DIR}/stm32/devices.cmake")

if(NOT STM32_FIND_COMPONENTS)
	set(STM32_FIND_COMPONENTS ${STM32_SUPPORTED_FAMILIES_LONG_NAMES})
endif()

list(REMOVE_DUPLICATES STM32_FIND_COMPONENTS)

message(STATUS "Search for STM32 families: ${STM32_FIND_COMPONENTS}")

foreach(COMP ${STM32_FIND_COMPONENTS})
	string(TOUPPER ${COMP} COMP_U)
	string(REGEX MATCH "^STM32([FGHLMUW]P?[0-9BL]).*$" COMP_U ${COMP_U})

	if(CMAKE_MATCH_1)
		set(FAMILY_U ${CMAKE_MATCH_1})
		string(TOLOWER ${FAMILY_U} FAMILY)
	else()
		message(FATAL_ERROR "FindSTM32: Unrecognized component pattern ${COMP}")
	endif()

	if(NOT (${FAMILY} IN_LIST STM32_SUPPORTED_FAMILIES))
		message(FATAL_ERROR "Invalid/unsupported STM32 FAMILY ${COMP}")
	endif()

	set(STM32_${COMP}_FOUND TRUE)

	stm32_get_family_subfamilies(${FAMILY} SUBFAMILIES)

	foreach(SUBFAMILY ${SUBFAMILIES})
		if(${SUBFAMILY} STREQUAL "")
			set(SUBFAMILY "")
			set(SUBFAMILY_C "")
			set(SUBFAMILY_U "")
		else()
			string(TOUPPER "${SUBFAMILY}" SUBFAMILY)
			set(SUBFAMILY_C "::${SUBFAMILY}")
			set(SUBFAMILY_U "_${SUBFAMILY}")
		endif()

		if (NOT (TARGET STM32::${FAMILY}${SUBFAMILY_C}))
			add_library(STM32::${FAMILY}${SUBFAMILY_C} INTERFACE IMPORTED)

			#=== Set compiler flags  ===
			target_compile_options(STM32::${FAMILY}${SUBFAMILY_C} INTERFACE
				$<$<C_COMPILER_ID:GNU>:-mthumb>
				$<$<C_COMPILER_ID:GNU>:-Wall>
				$<$<C_COMPILER_ID:GNU>:-ffunction-sections>
				$<$<C_COMPILER_ID:GNU>:-fdata-sections>
				$<$<AND:$<C_COMPILER_ID:GNU>,$<CONFIG:Debug>>:-g>
				${STM32_${FAMILY}${SUBFAMILY_U}_COMPILE_OPTIONS}
			)

			#=== Set linker flags ===
			target_link_options(STM32::${FAMILY}${SUBFAMILY_C} INTERFACE
				$<$<C_COMPILER_ID:GNU>:-mthumb>
				$<$<C_COMPILER_ID:GNU>:--Wl,--gc-sections>
				${STM32_${FAMILY}${SUBFAMILY_U}_LINK_OPTIONS}
			)

			#=== Set compiler definitions ===
			target_compile_definitions(STM32::${FAMILY}${SUBFAMILY_C} INTERFACE
				STM32${FAMILY}
			)
		endif()
	endforeach()
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
