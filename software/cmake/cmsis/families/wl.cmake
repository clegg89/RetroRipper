set(STM32_WL_SUBFAMILIES
	# All H7's have an M4
	M4
	# Dual-core variants also have an M0PLUS
	M0PLUS
)

set(STM32_WL_SUBFAMILY_PREFIX "CORE_")

set(STM32_WL_M4_TYPES 
	# Single-Core Lines
	WLE4xx WLE5xx
	# Dual-Core Lines
	WL54xx WL55xx
	# Implemented in CMSIS device header, but no product page
	WL5Mxx
)

set(STM32_WL_M0PLUS_TYPES
	# Dual-Core Lines
	WL54xx WL55xx
)

set(STM32_WL_TYPES ${STM32_WL_M4_TYPES} ${STM32_WL_M0PLUS_TYPES})
list(REMOVE_DUPLICATES STM32_WL_TYPES)

set(STM32_WLE4xx_DEVICES "WLE4..")
set(STM32_WLE5xx_DEVICES "WLE5..")
set(STM32_WL54xx_DEVICES "WL54..")
set(STM32_WL55xx_DEVICES "WL55..")
set(STM32_WL5Mxx_DEVICES "WL5M..")
