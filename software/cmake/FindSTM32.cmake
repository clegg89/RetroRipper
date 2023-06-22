# Adapted from https://github.com/ObKo/stm32-cmake
# Generate imported libraries for all supported STM32 chips and
# provide some utility functions.
#
# For a given part, i.e. the STM32F103RB we can break it down into:
#    * Family - What ST calls the "Series" (F1 in this example)
#    * Type - A subset of the family grouped by common functionality.
#      This directly corresponds to the macro definitions of each family's
#      HAL layer, a table of which can be found on the family's STM32Cube
#      "Getting Started" guide. They are also defined in the CMSIS Device
#      master include (i.e. stm32f1xx.h). In terms of ST nomenclature, it
#      most closely aligns to what ST calls "Product Line", though it is
#      not an exact match. For our example, the type is F103xB.
#    * Device - The full microcontroller part (F103RB). This simply
#      adds the information on the pin count and memory to the Type.
#
# We define interface libraries for both the Family and the Type.
# No library is needed at this level for the Device, as that is the
# domain of the CMSIS and HAL.
#
# The Family library is mainly concerned with compiler and linker
# flags, as this determines what CPU is being targetted and whether
# or not an FPU is available.
#
# The Type library typically adds a preprocessor definition for the type,
# (i.e. STM32F103xB) but does sometimes add additional compiler/linker
# flags.


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
	set(ARG_MULTIPLE TYPES)
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

	foreach(TYPE ${ARG_TYPES})
		if(NOT (TARGET STM32::${TYPE}${SUBFAMILY_C}))
			add_library(STM32::${TYPE}${SUBFAMILY_C} INTERFACE IMPORTED)
			target_link_libraries(STM32::${TYPE}${SUBFAMILY_C} INTERFACE STM32::${FAMILY})
			target_compile_definitions(STM32::${TYPE}${SUBFAMILY_C} INTERFACE
				STM32${TYPE}
			)
		endif()
	endforeach()
endfunction()

# Currently missing: c0 h5 wba
# TODO change to components of find package
set(FAMILIES
	# Mainstream
	f0 g0 f1 f3 g4
	# Ultra-low-power
	l0 l4 l5 u5
	# High Performance
	f2 f4 f7 h7
	# Wireless
	wl wb
)

foreach(FAMILY ${FAMILIES})
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

# TODO actually use find_package stuff