# Adapted from https://github.com/ObKo/stm32-cmake
#[=======================================================================[.md:
FindHAL
=======

Generate imported libraries for the requested STM32 families and HAL
components.

Components
----------
The caller may provide one or more families to generate HAL libraries for.
Families should be in the format `STM32${FAMILY}` where family is one of
the valid supported STM32 families.

Targets for the entire HAL of a family are created, though they are
separated into multiple peripheral libraries to optionally include/exclude
certain source files (which can speed up compilation).

Imported Targets
----------------
Each family will get a top level library which includes the bare-bones HAL
source files and include path.

Additional libraries will be created for each HAL "driver" (i.e. SPI, I2C)
which contains the appropriate source files for the driver. Each driver
may have up to 3 variants:
	* Regular (no prefix) - The basic driver
	* Low-Level (LL) - Low-level HAL driver
	* Extended (EX) - Extended driver
#]=======================================================================]

## Get a list of hal_driver components using a given prefix and suffix
#
# out_list_hal_drivers   list of hal_drivers found
# hal_drivers_path       path to the hal's drivers
# hal_driver_type        hal_driver type to find (hal/ll/ex)
function(get_list_hal_drivers out_list_hal_drivers hal_drivers_path hal_driver_type)
	#The pattern to retrieve a driver from a file name depends on the hal_driver_type field
	if(${hal_driver_type} STREQUAL "hal" OR ${hal_driver_type} STREQUAL "ll")
		#This regex match and capture a driver type (stm32xx_hal_(rcc).c or stm32xx_ll_(rcc).c => catches rcc) 
		set(file_pattern ".+_${hal_driver_type}_([a-z0-9]+)\\.c$")
	elseif(${hal_driver_type} STREQUAL "ex")
		#This regex match and capture a driver type (stm32xx_hal_(rcc)_ex.c => catches rcc) 
		set(file_pattern ".+_hal_([a-z0-9]+)_ex\\.c$")
	else()
		message(FATAL_ERROR "the inputed hal_driver_type(${hal_driver_type}) is not valid.")
	endif()

	#Retrieving all the .c files from hal_drivers_path
	file(GLOB filtered_files
		RELATIVE "${hal_drivers_path}/Src"
		"${hal_drivers_path}/Src/*.c")
	# For all matched .c files keep only those with a driver name pattern (e.g. stm32xx_hal_rcc.c)
	list(FILTER filtered_files INCLUDE REGEX ${file_pattern})
	# From the files names keep only the driver type part using the regex (stm32xx_hal_(rcc).c or stm32xx_ll_(rcc).c => catches rcc)
	list(TRANSFORM filtered_files REPLACE ${file_pattern} "\\1")
	#Making a return by reference by seting the output variable to PARENT_SCOPE
	set(${out_list_hal_drivers} ${filtered_files} PARENT_SCOPE)
endfunction()

if(NOT HAL_FIND_COMPONENTS)
	set(HAL_FIND_COMPONENTS ${STM32_SUPPORTED_FAMILIES_LONG_NAMES})
endif()

list(REMOVE_DUPLICATES HAL_FIND_COMPONENTS)

################################################################################
# Checking the parameters provided to the find_package(HAL ...) call
# The expected parameters are families
# Families are valid if on the list of known families.
#  - Step 1 : Checking all the requested families
#  - Step 2 : Generating all the valid drivers from requested families
################################################################################
# Step 1 : Checking all the requested families
foreach(COMP ${HAL_FIND_COMPONENTS})
	string(TOUPPER ${COMP} COMP_U)
	string(REGEX MATCH "^STM32([FGHLMUW]P?[0-9BL]).*$" COMP_U ${COMP_U})
	if(CMAKE_MATCH_1) #Matches the family part of the provided STM32<FAMILY>[..] component
		set(FAMILY ${CMAKE_MATCH_1})
		string(TOLOWER ${FAMILY} FAMILY_L)
		message(TRACE "FindHAL: append COMP ${COMP} to HAL_FIND_COMPONENTS_FAMILIES")
	else()
		message(FATAL_ERROR "FindHAL: Unrecognized component patter ${COMP}")
	endif()

	if(NOT (${FAMILY} IN_LIST STM32_SUPPORTED_FAMILIES))
		message(FATAL_ERROR "Invalid/unsupported STM32 FAMILY ${COMP}")
	endif()

	find_path(HAL_${FAMILY}_PATH
		NAMES Inc/stm32${FAMILY_L}xx_hal.h
		PATHS "${CMAKE_CURRENT_LIST_DIR}/../submodules/stm32"
		REQUIRED
		NO_DEFAULT_PATH
		)

	find_file(HAL_${FAMILY}_SOURCE
		NAMES stm32${FAMILY_L}xx_hal.c
		PATHS "${HAL_${FAMILY}_PATH}/Src"
		NO_DEFAULT_PATH
	)

	if (NOT HAL_${FAMILY}_PATH OR NOT HAL_${FAMILY}_SOURCE)
		set(HAL_${COMP}_FOUND FALSE)
		message(DEBUG "FindHAL: did not find path to HAL dir")
		continue()
	endif()

	set(HAL_${FAMILY}_INCLUDE "${HAL_${FAMILY}_PATH}/Inc")
	set(HAL_${COMP}_FOUND TRUE)

	get_list_hal_drivers(HAL_DRIVERS_${FAMILY} ${HAL_${FAMILY}_PATH} "hal")
	get_list_hal_drivers(HAL_EX_DRIVERS_${FAMILY} ${HAL_${FAMILY}_PATH}  "ex")
	get_list_hal_drivers(HAL_LL_DRIVERS_${FAMILY} ${HAL_${FAMILY}_PATH} "ll")

	stm32_get_family_subfamilies(${FAMILY} SUBFAMILIES)

	foreach(SUBFAMILY ${SUBFAMILIES})
		if(${SUBFAMILY} STREQUAL "")
			set(SUBFAMILY_C "")
		else()
			string(TOUPPER ${SUBFAMILY} SUBFAMILY)
			set(SUBFAMILY_C "::${SUBFAMILY}")
		endif()

		if(NOT (TARGET HAL::STM32::${FAMILY}${SUBFAMILY_C}))
			message(TRACE "FindHAL: creating library HAL::STM32::${FAMILY}${SUBFAMILY_C}")
			add_library(HAL::STM32::${FAMILY}${SUBFAMILY_C} INTERFACE IMPORTED)
			target_include_directories(HAL::STM32::${FAMILY}${SUBFAMILY_C} INTERFACE "${HAL_${FAMILY}_INCLUDE}")
			target_sources(HAL::STM32::${FAMILY}${SUBFAMILY_C} INTERFACE "${HAL_${FAMILY}_SOURCE}")
			target_link_libraries(HAL::STM32::${FAMILY}${SUBFAMILY_C} INTERFACE CMSIS::STM32::${FAMILY}${SUBFAMILY_C})
		endif()

		foreach(DRIVER ${HAL_DRIVERS_${FAMILY}})
			string(TOLOWER ${DRIVER} DRIVER_L)
			string(TOUPPER ${DRIVER} DRIVER)

			find_file(HAL_${FAMILY}_${DRIVER}_SOURCE
				NAMES stm32${FAMILY_L}xx_hal_${DRIVER_L}.c
				PATHS "${HAL_${FAMILY}_PATH}/Src"
				NO_DEFAULT_PATH
			)
			if(NOT HAL_${FAMILY}_${DRIVER}_SOURCE)
				message(WARNING "Cannot find ${DRIVER} driver for ${FAMILY}")
				continue()
			endif()
			list(APPEND HAL_${FAMILY}_SOURCES "${HAL_${FAMILY}_${DRIVER}_SOURCE}")

			if(NOT (TARGET HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER}))
				message(TRACE "FindHAL: creating library HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER}")
				add_library(HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER} INTERFACE IMPORTED)
				target_link_libraries(HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER} INTERFACE HAL::STM32::${FAMILY}${SUBFAMILY_C})
				target_sources(HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER} INTERFACE "${HAL_${FAMILY}_${DRIVER}_SOURCE}")
			endif()

			# We do this here instead of in a different loop since EX driver
			# needs to link to the regular driver (unlike the LL driver)
			if(${DRIVER_L} IN_LIST HAL_EX_DRIVERS_${FAMILY})
				find_file(HAL_${FAMILY}_${DRIVER}_EX_SOURCE
					NAMES stm32${FAMILY_L}xx_hal_${DRIVER_L}_ex.c
					PATHS "${HAL_${FAMILY}_PATH}/Src"
					NO_DEFAULT_PATH
				)
				if(NOT HAL_${FAMILY}_${DRIVER}_EX_SOURCE)
					message(WARNING "Cannot find ${DRIVER}Ex driver for ${FAMILY}")
					continue()
				endif()
				list(APPEND HAL_${FAMILY}_SOURCES "${HAL_${FAMILY}_${DRIVER}_EX_SOURCE}")
							
				if(NOT (TARGET HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER}Ex))
					message(TRACE "FindHAL: creating library HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER}Ex")
					add_library(HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER}Ex INTERFACE IMPORTED)
					target_link_libraries(HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER}Ex INTERFACE HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER})
					target_sources(HAL::STM32::${FAMILY}${SUBFAMILY_C}::${DRIVER}Ex INTERFACE "${HAL_${FAMILY}_${DRIVER}_EX_SOURCE}")
				endif()
			endif()
		endforeach()

		foreach(DRIVER ${HAL_LL_DRIVERS_${FAMILY}})
			string(TOLOWER ${DRIVER} DRIVER_L)
			string(REGEX REPLACE "^ll_" "" DRIVER_L ${DRIVER_L})
			string(TOUPPER ${DRIVER_L} DRIVER)

			find_file(HAL_${FAMILY}_${DRIVER}_LL_SOURCE
				NAMES stm32${FAMILY_L}xx_ll_${DRIVER_L}.c
				PATHS "${HAL_${FAMILY}_PATH}/Src"
				NO_DEFAULT_PATH
			)
			if(NOT HAL_${FAMILY}_${DRIVER}_LL_SOURCE)
				message(WARNING "Cannot find LL_${DRIVER} driver for ${FAMILY}")
				continue()
			endif()
			list(APPEND HAL_${FAMILY}_SOURCES "${HAL_${FAMILY}_${DRIVER}_LL_SOURCE}")

			if(NOT (TARGET HAL::STM32::${FAMILY}${SUBFAMILY_C}::LL_${DRIVER}))
				message(TRACE "FindHAL: creating library HAL::STM32::${FAMILY}${SUBFAMILY_C}::LL_${DRIVER}")
				add_library(HAL::STM32::${FAMILY}${SUBFAMILY_C}::LL_${DRIVER} INTERFACE IMPORTED)
				target_include_directories(HAL::STM32::${FAMILY}${SUBFAMILY_C}::LL_${DRIVER} INTERFACE "${HAL_${FAMILY}_INCLUDE}")
				target_sources(HAL::STM32::${FAMILY}${SUBFAMILY_C}::LL_${DRIVER} INTERFACE "${HAL_${FAMILY}_${DRIVER}_LL_SOURCE}")
				target_link_libraries(HAL::STM32::${FAMILY}${SUBFAMILY_C}::LL_${DRIVER} INTERFACE CMSIS::STM32::${FAMILY}${SUBFAMILY_C})
			endif()
		endforeach()
	endforeach()

	list(APPEND HAL_INCLUDE_DIRS "${HAL_${FAMILY}_INCLUDE}")
	list(APPEND HAL_SOURCES "${HAL_${FAMILY}_SOURCES}")
endforeach()

list(REMOVE_DUPLICATES HAL_INCLUDE_DIRS)
list(REMOVE_DUPLICATES HAL_SOURCES)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(HAL
	REQUIRED_VARS HAL_INCLUDE_DIRS HAL_SOURCES
	HANDLE_COMPONENTS
)
