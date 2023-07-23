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

foreach(FAMILY ${STM32_SUPPORTED_FAMILIES})
	string(TOUPPER ${FAMILY} FAMILY_U)
	list(APPEND ${FAMILY_U} STM32_SUPPORTED_FAMILIES_LONG_NAMES)

	find_file(STM32_${FAMILY}_FAMILY_INCLUDE
		"${FAMILY}.cmake"
		PATHS "${CMAKE_CURRENT_LIST_DIR}/families"
		REQUIRED
		NO_DEFAULT_PATH
		NO_CMAKE_PATH
		NO_CMAKE_FIND_ROOT_PATH
	)
	include("${STM32_${FAMILY}_FAMILY_INCLUDE}")
endforeach()

## For a given family provide a list of subfamilies, if it exists
#
# If a family has no subfamilies the result will be set to NONE
function(stm32_get_family_subfamilies FAMILY SUBFAMILIES)
	string(TOUPPER ${FAMILY} FAMILY)

	if(STM32_${FAMILY}_SUBFAMILIES)
		set(${SUBFAMILIES} ${STM32_${FAMILY}_SUBFAMILIES} PARENT_SCOPE)
	else()
		set(${SUBFAMILIES} "NONE" PARENT_SCOPE)
	endif()
endfunction()
