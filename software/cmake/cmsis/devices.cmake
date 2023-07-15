set(CMSIS_SUPPORTED_FAMILIES
	# Mainstream
	f0 g0 f1 f3 g4
	# Ultra-low-power
	l0 l4 l5 u5
	# High Performance
	f2 f4 f7 h7
	# Wireless
	wl wb
)

foreach(FAMILY ${CMSIS_SUPPORTED_FAMILIES})
	find_file(FAMILY_INCLUDE
		"${FAMILY}.cmake"
		PATHS "${CMAKE_CURRENT_LIST_DIR}/families"
		NO_CMAKE_PATH
		REQUIRED
	)
	include("${FAMILY_INCLUDE}")
endforeach()

function(cmsis_stm32_get_family_types FAMILY TYPES)
	string(TOUPPER ${FAMILY} FAMILY)

	if(NOT STM32_${FAMILY}_TYPES)
		message(FATAL_ERROR "Invalid/unsupported FAMILY ${FAMILY}")
	endif()

	set(${TYPES} ${STM32_${FAMILY}_TYPES} PARENT_SCOPE)
endfunction()

function(cmsis_stm32_get_type_subfamilies TYPE SUBFAMILIES)
	string(TOUPPER ${TYPE} TYPE)
    string(REGEX MATCH "^[FGHLMUW]P?[0-9BL]" FAMILY ${TYPE})

	if(NOT FAMILY)
		message(FATAL_ERROR "Unkown TYPE pattern ${TYPE}")
	endif()

	foreach(C_SUBFAM ${STM32_${FAMILY}_SUBFAMILIES})
	 	if(${TYPE} IN_LIST STM32_${FAMILY}_${C_SUBFAM}_TYPES)
			list(APPEND RESULT_SUBFAMILIES ${C_SUBFAM})
		endif()
	endforeach()

	if(RESULT_SUBFAMILIES)
		set(${SUBFAMILIES} ${RESULT_SUBFAMILIES} PARENT_SCOPE)
	endif()
endfunction()

function(cmsis_stm32_get_subfamily_definitions FAMILY SUBFAMILY DEFINITIONS)
	string(TOUPPER ${FAMILY} FAMILY)
	string(TOUPPER ${SUBFAMILY} SUBFAMILY)

	if(${SUBFAMILY} NOT IN_LIST STM32_${FAMILY}_SUBFAMILIES)
		message(FATAL_ERROR "Invalid/unsupported SUBFAMILY ${SUBFAMILY} of FAMILY ${FAMILY}")
	endif()

	if(STM32_${FAMILY}_SUBFAMILY_PREFIX)
		set(${DEFINITIONS} "${STM32_${FAMILY}_SUBFAMILY_PREFIX}${SUBFAMILY}" PARENT_SCOPE)
	endif()
endfunction()

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
