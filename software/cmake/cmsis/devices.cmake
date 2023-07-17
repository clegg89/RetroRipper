foreach(FAMILY ${STM32_SUPPORTED_FAMILIES})
	find_file(FAMILY_INCLUDE
		"${FAMILY}.cmake"
		PATHS "${CMAKE_CURRENT_LIST_DIR}/families"
		NO_CMAKE_PATH
		REQUIRED
	)
	include("${FAMILY_INCLUDE}")
endforeach()

## Given a family FAMILY, output the supported types in TYPES
function(cmsis_stm32_get_family_types FAMILY TYPES)
	string(TOUPPER ${FAMILY} FAMILY)

	if(NOT STM32_${FAMILY}_TYPES)
		message(FATAL_ERROR "Invalid/unsupported FAMILY ${FAMILY}")
	endif()

	set(${TYPES} ${STM32_${FAMILY}_TYPES} PARENT_SCOPE)
endfunction()

## Given a type TYPE, output all supported subfamilies (if any) in SUBFAMILIES
function(cmsis_stm32_get_type_subfamilies TYPE SUBFAMILIES)
	string(TOUPPER ${TYPE} TYPE)
    string(REGEX MATCH "^[FGHLMUW]P?[0-9BL]" FAMILY ${TYPE})

	if(NOT FAMILY)
		message(FATAL_ERROR "Unkown TYPE pattern ${TYPE}")
	endif()

	stm32_get_family_subfamilies(${FAMILY} C_SUBFAMILIES)

	if(${C_SUBFAMILIES} STREQUAL "")
		set(${SUBFAMILIES} "" PARENT_SCOPE)
	else()
		set(RESULT_SUBFAMILIES "")
		foreach(SUBFAMILY ${C_SUBFAMILIES})
			if(${TYPE} IN_LIST STM32_${FAMILY}_${SUBFAMILY}_TYPES)
				list(APPEND RESULT_SUBFAMILIES ${SUBFAMILY})
			endif()
		endforeach()

		set(${SUBFAMILIES} ${RESULT_SUBFAMILIES} PARENT_SCOPE)
	endif()
endfunction()

## Provides preprocessor definitions for a family's subfamily
function(_cmsis_stm32_get_subfamily_definitions FAMILY SUBFAMILY DEFINITIONS)
	string(TOUPPER ${FAMILY} FAMILY)
	string(TOUPPER ${SUBFAMILY} SUBFAMILY)

	if(${SUBFAMILY} NOT IN_LIST STM32_${FAMILY}_SUBFAMILIES)
		message(FATAL_ERROR "Invalid/unsupported SUBFAMILY ${SUBFAMILY} of FAMILY ${FAMILY}")
	endif()

	if(STM32_${FAMILY}_SUBFAMILY_PREFIX)
		set(${DEFINITIONS} "${STM32_${FAMILY}_SUBFAMILY_PREFIX}${SUBFAMILY}" PARENT_SCOPE)
	endif()
endfunction()

## Given a device DEVICE, output the device's type to TYPE
function(cmsis_stm32_get_device_type DEVICE TYPE)
	string(TOUPPER ${DEVICE} DEVICE)
    string(REGEX MATCH "^[FGHLMUW]P?[0-9BL]" FAMILY ${DEVICE})

	if(NOT FAMILY)
		message(FATAL_ERROR "Unkown DEVICE pattern ${DEVICE}")
	endif()

	foreach(C_TYPE ${STM32_${FAMILY}_TYPES})
		if(${DEVICE} MATCHES ${STM32_${C_TYPE}_DEVICES})
			set(RESULT_TYPE ${C_TYPE})
		endif()
	endforeach()

	if(NOT RESULT_TYPE)
		message(FATAL_ERROR "Invalid/unsupported device: ${DEVICE}")
	endif()

	set(${TYPE} ${RESULT_TYPE} PARENT_SCOPE)
endfunction()
